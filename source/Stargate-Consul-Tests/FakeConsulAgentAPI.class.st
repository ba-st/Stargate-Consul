"
I'm a fake object. I will impersonate the Consul Agent HTTP API, and can be used in tests without requiring a real Consul installation.
"
Class {
	#name : #FakeConsulAgentAPI,
	#superclass : #Object,
	#instVars : [
		'server',
		'registeredServices',
		'asserter',
		'isFirstRegisterRequestReceived',
		'isFirstDeregisterRequestReceived'
	],
	#category : #'Stargate-Consul-Tests'
}

{ #category : #'instance creation' }
FakeConsulAgentAPI class >> configuredBy: configuration on: aTestAsserter [

	^ self new initializeConfiguredBy: configuration on: aTestAsserter
]

{ #category : #initialization }
FakeConsulAgentAPI >> configureTeapotServerWith: configuration [

	server := Teapot configure: configuration.
	server
		PUT: '/v1/agent/service/register' -> [ :request | self handleServiceRegistration: request ];
		PUT:
			'/v1/agent/service/deregister/<identifier:IsObject>'
				-> [ :request | self handleServiceDeregistration: request ]
]

{ #category : #private }
FakeConsulAgentAPI >> handleServiceDeregistration: request [

	"I will fail on purpose the first request to te be able to test the retry mechanics"

	^ isFirstDeregisterRequestReceived
		  then: [ 
			  isFirstDeregisterRequestReceived := false.
			  TeaResponse serverError
			  ]
		  otherwise: [ 
			  | serviceId |

			  asserter assert: request method equals: #PUT.
			  serviceId := request at: #identifier.
			  registeredServices removeAllSuchThat: [ :service | service ID = serviceId ].
			  TeaResponse ok
			  ]
]

{ #category : #private }
FakeConsulAgentAPI >> handleServiceRegistration: request [

	"I will fail on purpose the first request to te be able to test the retry mechanics"

	^ isFirstRegisterRequestReceived
		  then: [ 
			  isFirstRegisterRequestReceived := false.
			  TeaResponse serverError
			  ]
		  otherwise: [ 
			  | service |

			  asserter
				  assert: request method equals: #PUT;
				  assert: request contents notEmpty.
			  service := NeoJSONObject fromString: request contents.
			  service at: #ID ifAbsentPut: [ service at: #Name ].
			  registeredServices add: service.
			  TeaResponse ok
			  ]
]

{ #category : #initialization }
FakeConsulAgentAPI >> initializeConfiguredBy: configuration on: aTestAsserter [

	registeredServices := OrderedCollection new.
	asserter := aTestAsserter.
	isFirstRegisterRequestReceived := true.
	isFirstDeregisterRequestReceived := true.
	self configureTeapotServerWith: configuration
]

{ #category : #accessing }
FakeConsulAgentAPI >> registeredServiceCount [

	^ registeredServices size
]

{ #category : #accessing }
FakeConsulAgentAPI >> registeredServices [

	^ registeredServices
]

{ #category : #controlling }
FakeConsulAgentAPI >> start [

	server start
]

{ #category : #controlling }
FakeConsulAgentAPI >> stop [

	server stop
]
