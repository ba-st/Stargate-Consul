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
ConsulServiceDiscoveryPlugin >> deregistrationUrlFor: serviceDefinition [

	| serviceId |

	serviceId := serviceDefinition at: #ID ifAbsent: [ serviceDefinition Name ].

	^ consulAgentLocation / ( 'agent/service/deregister/<1s>' expandMacrosWith: serviceId )
]

{ #category : #configuring }
ConsulServiceDiscoveryPlugin >> includeControllersIn: api [
]

{ #category : #initialization }
ConsulServiceDiscoveryPlugin >> initializeReportingLifecycleOfAll: aServiceDefinitionCollection toAgentOn: aConsulAPIUrl [

	serviceDefinitions := aServiceDefinitionCollection.
	consulAgentLocation := aConsulAPIUrl
]

{ #category : #controlling }
ConsulServiceDiscoveryPlugin >> startOn: teapotServer [

	serviceDefinitions
		do: [ :serviceDefinition | 
			ZnClient new
				beOneShot;
				enforceHttpSuccess;
				put: consulAgentLocation / 'agent/service/register'
					contents: ( NeoJSONWriter toString: serviceDefinition )
			]
]

{ #category : #controlling }
ConsulServiceDiscoveryPlugin >> stop [

	serviceDefinitions
		do: [ :serviceDefinition | 
			ZnClient new
				beOneShot;
				enforceHttpSuccess;
				put: ( self deregistrationUrlFor: serviceDefinition ) contents: ''
			]
]
