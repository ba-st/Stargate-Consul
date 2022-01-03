Class {
	#name : #ConsulServiceDiscoveryPluginAPITest,
	#superclass : #OperationalPluginAPITest,
	#instVars : [
		'consulAgent',
		'consulAgentPort'
	],
	#category : #'Stargate-Consul-Tests'
}

{ #category : #private }
ConsulServiceDiscoveryPluginAPITest >> consulAgentLocation [

	^ 'http://localhost' asUrl port: consulAgentPort
]

{ #category : #running }
ConsulServiceDiscoveryPluginAPITest >> isLogging [

	^ true
]

{ #category : #private }
ConsulServiceDiscoveryPluginAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ConsulServiceDiscoveryPlugin endpoint
			put: {
				#enabled -> true.
				#definitions -> self serviceDefinitions.
				#consulAgentLocation -> self consulAgentLocation
			} asDictionary;
		yourself
]

{ #category : #private }
ConsulServiceDiscoveryPluginAPITest >> requiredPermissions [

	^ #()
]

{ #category : #running }
ConsulServiceDiscoveryPluginAPITest >> runCase [

	| logs |
	logs := String streamContents: [ :stream | 
		        | logger |
		        logger := MemoryLogger new runDuring: [ super runCase ].
		        logger recordings
			        do: [ :event | stream nextPutAll: event printString ]
			        separatedBy: [ stream cr ] ].
	self logFailure: logs
]

{ #category : #private }
ConsulServiceDiscoveryPluginAPITest >> serviceDefinitions [

	^ { ConsulServiceDefinitionBuilder new buildNamed: 'test' }
]

{ #category : #running }
ConsulServiceDiscoveryPluginAPITest >> setUp [

	consulAgentPort := self freeListeningTCPPort.
	consulAgent := FakeConsulAgentAPI
		configuredBy:
			{( #port -> consulAgentPort ).
			( #serverUrl -> self consulAgentLocation ).
			( #debugMode -> true )}
		on: self.
	consulAgent start.
	super setUp
]

{ #category : #running }
ConsulServiceDiscoveryPluginAPITest >> tearDown [

	super tearDown.
	self assert: consulAgent registeredServiceCount equals: 0.
	consulAgent stop
]

{ #category : #tests }
ConsulServiceDiscoveryPluginAPITest >> testPluginIsEnabled [

	self
		assertIsEnabled: ConsulServiceDiscoveryPlugin;
		assert: consulAgent registeredServiceCount equals: 1
]
