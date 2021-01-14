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

{ #category : #logging }
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

{ #category : #private }
ConsulServiceDiscoveryPluginAPITest >> runCase [

	| logs |

	logs :=
		String streamContents: [:stream |
			CurrentLogger
				value: (LeveledLogger outputTo: stream errorsTo: stream)
				during: [super runCase]].
	self logFailure: logs
]

{ #category : #private }
ConsulServiceDiscoveryPluginAPITest >> serviceDefinitions [

	^ { ConsulServiceDefinitionBuilder new buildNamed: 'test' }
]

{ #category : #tests }
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

{ #category : #tests }
ConsulServiceDiscoveryPluginAPITest >> tearDown [

	super tearDown.
	self assert: consulAgent registeredServiceCount equals: 0.
	consulAgent stop
]

{ #category : #tests }
ConsulServiceDiscoveryPluginAPITest >> testPluginIsEnabled [

	self
		assert: ( api isEnabled: ConsulServiceDiscoveryPlugin );
		assert: consulAgent registeredServiceCount equals: 1
]
