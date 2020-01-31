"
A ConsulServiceDiscoveryPluginTest is a test class for testing the behavior of ConsulServiceDiscoveryPlugin
"
Class {
	#name : #ConsulServiceDiscoveryPluginTest,
	#superclass : #TestCase,
	#category : #'Stargate-Consul-Tests'
}

{ #category : #tests }
ConsulServiceDiscoveryPluginTest >> testEnabledByDefault [

	self deny: ConsulServiceDiscoveryPlugin enabledByDefault
]

{ #category : #tests }
ConsulServiceDiscoveryPluginTest >> testEndpoint [

	self assert: ConsulServiceDiscoveryPlugin endpoint equals: 'consul-service-discovery'
]

{ #category : #tests }
ConsulServiceDiscoveryPluginTest >> testPluginName [

	self assert: ConsulServiceDiscoveryPlugin pluginName equals: 'Consul Service Discovery'
]
