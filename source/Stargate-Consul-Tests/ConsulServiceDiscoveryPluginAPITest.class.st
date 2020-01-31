Class {
	#name : #ConsulServiceDiscoveryPluginAPITest,
	#superclass : #OperationalPluginAPITest,
	#instVars : [
		'consulAgent'
	],
	#category : #'Stargate-Consul-Tests'
}

{ #category : #private }
ConsulServiceDiscoveryPluginAPITest >> consulAgentLocation [

	^ 'http://localhost:9998' asUrl
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
ConsulServiceDiscoveryPluginAPITest >> serviceDefinitions [

	^ { ConsulServiceDefinitionBuilder new buildNamed: 'test' }
]

{ #category : #tests }
ConsulServiceDiscoveryPluginAPITest >> setUp [

	consulAgent := FakeConsulAgentAPI
		configuredBy:
			{( #port -> 9998 ).
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
