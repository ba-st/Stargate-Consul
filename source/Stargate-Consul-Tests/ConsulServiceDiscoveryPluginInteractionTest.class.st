Class {
	#name : #ConsulServiceDiscoveryPluginInteractionTest,
	#superclass : #TestCase,
	#instVars : [
		'consulAgent'
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

{ #category : #accessing }
ConsulServiceDiscoveryPluginInteractionTest >> port [

	^ 9998
]

{ #category : #running }
ConsulServiceDiscoveryPluginInteractionTest >> setUp [

	super setUp.
	consulAgent := FakeConsulAgentAPI
		configuredBy:
			{( #port -> self port ).
			( #serverUrl -> self baseUrl ).
			( #debugMode -> true )}
		on: self.
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

	self assert: consulAgent registeredServices isEmpty.

	plugin startOn: self apiServer.

	self
		withTheOnlyOneIn: consulAgent registeredServices
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

	self assert: consulAgent registeredServices isEmpty.

	plugin startOn: self apiServer.

	self assert: consulAgent registeredServiceCount equals: 1.

	plugin stop.

	self assert: consulAgent registeredServices isEmpty
]
