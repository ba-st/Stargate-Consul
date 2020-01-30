Class {
	#name : #ConsulServiceDiscoveryPluginInteractionTest,
	#superclass : #TestCase,
	#instVars : [
		'consulAgent',
		'registeredServices'
	],
	#category : #'Stargate-Consul-Tests'
}

{ #category : #accessing }
ConsulServiceDiscoveryPluginInteractionTest >> apiServer [
	
	^ Teapot new
]

{ #category : #accessing }
ConsulServiceDiscoveryPluginInteractionTest >> baseUrl [

	^ 'http://localhost' asUrl port: self port
]

{ #category : #running }
ConsulServiceDiscoveryPluginInteractionTest >> configureConsulAgent [

	"I will simulate the Consul Agent HTTP API"

	consulAgent
		PUT:
			'/agent/service/register'
				-> [ :request | 
					self handleServiceRegistrationFrom: request.
					TeaResponse ok
					];
		PUT:
			'/agent/service/deregister/<identifier:IsObject>'
				-> [ :request | 
					self handleServiceDeregistrationFrom: request.
					TeaResponse ok
					]
]

{ #category : #running }
ConsulServiceDiscoveryPluginInteractionTest >> handleServiceDeregistrationFrom: request [

	| serviceId |

	self assert: request method equals: #PUT.
	serviceId := request at: #identifier.
	registeredServices removeAllSuchThat: [ :service | service ID = serviceId ]
]

{ #category : #running }
ConsulServiceDiscoveryPluginInteractionTest >> handleServiceRegistrationFrom: request [

	| service |

	self
		assert: request method equals: #PUT;
		assert: request contents notEmpty.
	service := NeoJSONObject fromString: request contents.
	service at: #ID ifAbsentPut: [ service at: #Name ].
	registeredServices add: service
]

{ #category : #accessing }
ConsulServiceDiscoveryPluginInteractionTest >> port [

	^ 9998
]

{ #category : #running }
ConsulServiceDiscoveryPluginInteractionTest >> setUp [

	super setUp.
	registeredServices := OrderedCollection new.
	consulAgent := Teapot
		configure: { #port -> self port. #serverUrl -> self baseUrl. #debugMode -> true }.
	self configureConsulAgent.
	consulAgent start
]

{ #category : #running }
ConsulServiceDiscoveryPluginInteractionTest >> tearDown [

	consulAgent stop.
	super tearDown
]

{ #category : #tests }
ConsulServiceDiscoveryPluginInteractionTest >> testStartOn [

	| plugin |

	plugin := ConsulServiceDiscoveryPlugin
		reportingLifecycleOf: ( ConsulServiceDefinitionBuilder new buildNamed: 'test' )
		toAgentOn: self baseUrl.

	self assert: registeredServices isEmpty.

	plugin startOn: self apiServer.

	self
		withTheOnlyOneIn: registeredServices
		do: [ :registeredService | 
			self
				assert: registeredService Name equals: 'test';
				assert: registeredService ID equals: 'test'
			]
]

{ #category : #tests }
ConsulServiceDiscoveryPluginInteractionTest >> testStop [

	| plugin |

	plugin := ConsulServiceDiscoveryPlugin
		reportingLifecycleOf: ( ConsulServiceDefinitionBuilder new buildNamed: 'test' )
		toAgentOn: self baseUrl.

	self assert: registeredServices isEmpty.

	plugin startOn: self apiServer.

	self assert: registeredServices size equals: 1.

	plugin stop.

	self assert: registeredServices isEmpty
]
