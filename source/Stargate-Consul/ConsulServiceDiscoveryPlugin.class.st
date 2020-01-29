"
I'm one of the operational plugins.
I provide support for registering and deregistering services on a Consul Agent (https://www.consul.io/) using the HTTP API.
"
Class {
	#name : #ConsulServiceDiscoveryPlugin,
	#superclass : #OperationalPlugin,
	#category : #'Stargate-Consul'
}

{ #category : #configuring }
ConsulServiceDiscoveryPlugin class >> configureMediaControlsIn: builder within: requestContext [


]

{ #category : #accessing }
ConsulServiceDiscoveryPlugin class >> endpoint [

	^ 'consul-service-discovery'
]

{ #category : #accessing }
ConsulServiceDiscoveryPlugin class >> pluginName [

	^ 'Consul Service Discovery'
]

{ #category : #configuring }
ConsulServiceDiscoveryPlugin >> includeControllersIn: api [
]
