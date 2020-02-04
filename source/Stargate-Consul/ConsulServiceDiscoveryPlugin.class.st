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
ConsulServiceDiscoveryPlugin >> deregistrationUrlFor: serviceDefinition [

	| serviceId |

	serviceId := serviceDefinition at: #ID ifAbsent: [ serviceDefinition Name ].

	^ self baseAPILocation / ( 'deregister/<1s>' expandMacrosWith: serviceId )
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
			self
				try: [ :client | 
					client
						put: self baseAPILocation / 'register'
						contents: ( NeoJSONWriter toString: serviceDefinition )
					]
				retryCount: 3
			]
]

{ #category : #controlling }
ConsulServiceDiscoveryPlugin >> stop [

	serviceDefinitions
		do: [ :serviceDefinition | 
			self
				try: [ :client | client put: ( self deregistrationUrlFor: serviceDefinition ) contents: '' ]
				retryCount: 3
			]
]

{ #category : #private }
ConsulServiceDiscoveryPlugin >> try: aBlock retryCount: count [

	| client |

	client := ZnClient new.
	client
		beOneShot;
		enforceHttpSuccess: true.
	count = 1
		ifTrue: [ aBlock value: client ]
		ifFalse: [ [ aBlock value: client ]
				on: ZnHttpUnsuccessful
				do: [ :error | 
					CurrentLogger value
						logAsError:
							( 'Consul Agent HTTP request failed: <1s>, retry count: <2p>' expandMacrosWith: error messageText with: count ).
					self try: aBlock retryCount: count - 1
					]
			]
]
