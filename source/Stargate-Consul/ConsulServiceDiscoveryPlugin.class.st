"
I'm one of the operational plugins.
I provide support for registering and deregistering services on a Consul Agent (https://www.consul.io/) using the HTTP API.
"
Class {
	#name : #ConsulServiceDiscoveryPlugin,
	#superclass : #OperationalPlugin,
	#instVars : [
		'apiClient',
		'options'
	],
	#category : #'Stargate-Consul'
}

{ #category : #configuring }
ConsulServiceDiscoveryPlugin class >> configureMediaControlsIn: builder within: requestContext [


]

{ #category : #'instance creation' }
ConsulServiceDiscoveryPlugin class >> configuredBy: configuration [

	^ self with: ( self pluginConfigurationOn: configuration )
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

	^ self with: ( Dictionary new
			    at: #definitions put: { aServiceDefinition };
			    at: #consulAgentLocation put: aConsulAPIUrl;
			    yourself )
]

{ #category : #'private - instance creation' }
ConsulServiceDiscoveryPlugin class >> with: options [

	^self new initializeWith: options
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> baseAPILocation [

	^ self consulAgentLocation / 'v1/agent/service'
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> connectivityErrors [

	^ HTTPError , NetworkError
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> consulAgentLocation [

	^ ( options at: #consulAgentLocation ifAbsent: [ 'http://localhost:8500' ] ) asUrl
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> deregisterFromConsul: serviceDefinition [

	apiClient
		putAt: ( self deregistrationUrlFor: serviceDefinition )
		configuredBy: [ :request | request body json: Dictionary new ]
		withSuccessfulResponseDo: [ :contents |  ]
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
ConsulServiceDiscoveryPlugin >> initializeWith: configurationOptions [

	options := configurationOptions.
	apiClient := RESTfulAPIClient cachingOnLocalMemory
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> logDeregistrationFailedAtAttempt: attemptNumber dueTo: error [

	LogRecord emitError:
		('Attempt #<1p>/<2p> to deregister service in Consul Agent failed: <3s>'
			 expandMacrosWith: attemptNumber
			 with: self retryCount + 1
			 with: error messageText)
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> logRegistrationFailedAtAttempt: attemptNumber dueTo: error [

	LogRecord emitError:
		('Attempt #<1p>/<2p> to register service in Consul Agent failed: <3s>'
			 expandMacrosWith: attemptNumber
			 with: self retryCount + 1
			 with: error messageText)
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> registerToConsul: serviceDefinition [

	apiClient
		putAt: self baseAPILocation / 'register'
		configuredBy: [ :request | request body json: serviceDefinition ]
		withSuccessfulResponseDo: [ :contents |  ]
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> retryCount [

	^ 2
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> serviceDefinitions [

	^ options at: #definitions
]

{ #category : #controlling }
ConsulServiceDiscoveryPlugin >> startOn: teapotServer [

	self serviceDefinitions do: [ :serviceDefinition | 
		self
			try: [ self registerToConsul: serviceDefinition ]
			onConnectivityErrorDo: [ :attemptNumber :error | 
			self logRegistrationFailedAtAttempt: attemptNumber dueTo: error ]
		]
]

{ #category : #controlling }
ConsulServiceDiscoveryPlugin >> stop [

	self ignoreConnectivityErrorsDuring: [ 
		"Since we are already stopping the API, just ignore it after the number of retries failed. 
		Consul will figure out eventually that this service is dead."
		self serviceDefinitions do: [ :serviceDefinition | 
			self
				try: [ self deregisterFromConsul: serviceDefinition ]
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
			on: self connectivityErrors evaluating: failBlock.
		options at: #retry ifPresent: [ :action | action value: retry ]
		]
]
