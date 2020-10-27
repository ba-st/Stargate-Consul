"
I'm one of the operational plugins.
I provide support for registering and deregistering services on a Consul Agent (https://www.consul.io/) using the HTTP API.
"
Class {
	#name : #ConsulServiceDiscoveryPlugin,
	#superclass : #OperationalPlugin,
	#instVars : [
		'serviceDefinitions',
		'consulAgentLocation'
	],
	#category : #'Stargate-Consul'
}

{ #category : #configuring }
ConsulServiceDiscoveryPlugin class >> configureMediaControlsIn: builder within: requestContext [


]

{ #category : #'instance creation' }
ConsulServiceDiscoveryPlugin class >> configuredBy: configuration [

	| selfConfiguration |

	selfConfiguration := self pluginConfigurationOn: configuration.
	^ self
		reportingLifecycleOfAll: ( selfConfiguration at: #definitions )
		toAgentOn: ( selfConfiguration at: #consulAgentLocation ifAbsent: [ 'http://localhost:8500' asUrl ] )
]

{ #category : #accessing }
ConsulServiceDiscoveryPlugin class >> endpoint [

	^ 'consul-service-discovery'
]

{ #category : #accessing }
ConsulServiceDiscoveryPlugin class >> pluginName [

	^ 'Consul Service Discovery'
]

{ #category : #'instance creation' }
ConsulServiceDiscoveryPlugin class >> reportingLifecycleOf: aServiceDefinition toAgentOn: aConsulAPIUrl [

	^ self reportingLifecycleOfAll: ( Array with: aServiceDefinition ) toAgentOn: aConsulAPIUrl
]

{ #category : #'instance creation' }
ConsulServiceDiscoveryPlugin class >> reportingLifecycleOfAll: aServiceDefinitionCollection toAgentOn: aConsulAPIUrl [

	^ self new initializeReportingLifecycleOfAll: aServiceDefinitionCollection toAgentOn: aConsulAPIUrl
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> baseAPILocation [

	^ consulAgentLocation / 'v1/agent/service'
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> connectivityErrors [

	^ ZnHttpUnsuccessful , NetworkError
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> deregisterFromConsul: serviceDefinition [

	^ self newHttpClient put: ( self deregistrationUrlFor: serviceDefinition ) contents: ''
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> deregistrationUrlFor: serviceDefinition [

	| serviceId |

	serviceId := serviceDefinition at: #ID ifAbsent: [ serviceDefinition Name ].

	^ self baseAPILocation / ( 'deregister/<1s>' expandMacrosWith: serviceId )
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> ignoreConnectivityErrorsDuring: aBlock [

	aBlock on: self connectivityErrors
		do: [ :error | error return ]
]

{ #category : #configuring }
ConsulServiceDiscoveryPlugin >> includeControllersIn: api [
]

{ #category : #initialization }
ConsulServiceDiscoveryPlugin >> initializeReportingLifecycleOfAll: aServiceDefinitionCollection toAgentOn: aConsulAPIUrl [

	serviceDefinitions := aServiceDefinitionCollection.
	consulAgentLocation := aConsulAPIUrl
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> logDeregistrationFailedAtAttempt: attemptNumber dueTo: error [

	CurrentLogger value logAsError:
		( 'Attempt #<1p>/<2p> to deregister service in Consul Agent failed: <3s>' expandMacrosWith:
			  attemptNumber
			  with: self retryCount + 1
			  with: error messageText )
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> logRegistrationFailedAtAttempt: attemptNumber dueTo: error [

	CurrentLogger value logAsError:
		( 'Attempt #<1p>/<2p> to register service in Consul Agent failed: <3s>' expandMacrosWith:
			  attemptNumber
			  with: self retryCount + 1
			  with: error messageText )
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> newHttpClient [

	^ ZnClient new
		  beOneShot;
		  enforceHttpSuccess: true;
		  yourself
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> registerToConsul: serviceDefinition [

	^ self newHttpClient put: self baseAPILocation / 'register'
		  contents: ( NeoJSONWriter toString: serviceDefinition )
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> retryCount [

	^ 2
]

{ #category : #controlling }
ConsulServiceDiscoveryPlugin >> startOn: teapotServer [

	serviceDefinitions do: [ :serviceDefinition | 
		self try: [ self registerToConsul: serviceDefinition ]
			onConnectivityErrorDo: [ :attemptNumber :error | 
			self logRegistrationFailedAtAttempt: attemptNumber dueTo: error ]
		]
]

{ #category : #controlling }
ConsulServiceDiscoveryPlugin >> stop [

	self ignoreConnectivityErrorsDuring: [ 
		"Since we are already stopping the API, just ignore it after the number of retries failed. 
		Consul will figure out eventually that this service is dead."
		serviceDefinitions do: [ :serviceDefinition | 
			self try: [ self deregisterFromConsul: serviceDefinition ]
				onConnectivityErrorDo: [ :attemptNumber :error | 
				self logDeregistrationFailedAtAttempt: attemptNumber dueTo: error ]
			]
		]
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> try: aBlock onConnectivityErrorDo: failBlock [

	Retry value: aBlock configuredBy: [ :retry | 
		retry
			upTo: self retryCount;
			on: self connectivityErrors evaluating: failBlock
		]
]
