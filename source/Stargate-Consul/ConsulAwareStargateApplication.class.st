Class {
	#name : #ConsulAwareStargateApplication,
	#superclass : #StargateApplication,
	#category : #'Stargate-Consul'
}

{ #category : #testing }
ConsulAwareStargateApplication class >> isAbstract [

	^ self = ConsulAwareStargateApplication
]

{ #category : #'*Stargate-Consul' }
ConsulAwareStargateApplication class >> stargateConfigurationParameters [

	^ super stargateConfigurationParameters , { MandatoryConfigurationParameter
		    named: 'Consul Agent Location'
		    describedBy: 'Location of the Consul Agent. Leave empty to disable the plugin'
		    inside: self sectionsForStargateConfiguration
		    convertingWith: #asUrl }
]

{ #category : #'private - building' }
ConsulAwareStargateApplication >> buildServiceDefinitionNamed: serviceName configuredBy: aBlock [

	| builder |

	builder := ConsulServiceDefinitionBuilder new.
	self
		configureDockerHostnameFor: serviceName in: builder;
		configureHealthCheckIn: builder;
		configureMetadataIn: builder.

	builder port: self stargateConfiguration port.
	aBlock cull: builder.

	^ builder buildNamed: serviceName
]

{ #category : #'private - building' }
ConsulAwareStargateApplication >> configureDockerHostnameFor: serviceName in: builder [

	self
		withDockerHostnameDo: [ :hostname | 
			builder
				identifiedBy: ( '<1s>-<2s>' expandMacrosWith: serviceName with: hostname );
				address: hostname
			]
		ifAbsent: [  ]
]

{ #category : #'private - building' }
ConsulAwareStargateApplication >> configureHealthCheckIn: builder [

	builder addCheck: ( ConsulAgentHTTPBasedCheck
			  named: 'health-check'
			  executing: #POST
			  against: self healthCheckEndpoint
			  withHeaders: { 
					  #accept -> 'application/vnd.stargate.health-check.summary+json;version=1.0.0'.
					  #authorization -> ( 'Bearer <1s>' expandMacrosWith: self healthCheckToken ) }
			  every: self serviceDiscoveryHealthCheckInterval
			  timeoutAfter: self serviceDiscoveryHealthCheckTimeout )
]

{ #category : #'private - building' }
ConsulAwareStargateApplication >> configureMetadataIn: builder [

	BasicApplicationInformationProvider new gatherInformation keysAndValuesDo: [ :key :value | 
		builder metadataAt: key put: value ]
]

{ #category : #'private - accessing' }
ConsulAwareStargateApplication >> consulServiceDiscoveryConfiguration [

	^ Dictionary new
		  at: #enabled put: self isServiceDiscoveryThroughConsulEnabled;
		  at: #definitions put: self serviceDefinitions;
		  at: #consulAgentLocation put: self stargateConfiguration consulAgentLocation;
		  yourself
]

{ #category : #'private - building' }
ConsulAwareStargateApplication >> healthCheckEndpoint [

	| baseUrl |

	baseUrl := self
		           withDockerHostnameDo: [ :hostname | 
			           ZnUrl new
				           host: hostname;
				           port: self stargateConfiguration port;
				           yourself
			           ]
		           ifAbsent: [ self stargateConfiguration publicURL ].

	^ baseUrl / 'operations' asUrl / HealthCheckPlugin endpoint
]

{ #category : #'private - building' }
ConsulAwareStargateApplication >> healthCheckToken [

	| jws |

	jws := JsonWebSignature new.
	jws algorithmName: self authAlgorithm.
	jws payload: ( JWTClaimsSet new
			  permissions: #( 'execute:health-check' );
			  yourself ).
	jws key: self stargateConfiguration operationsSecret.
	^ jws compactSerialized
]

{ #category : #'private - accessing' }
ConsulAwareStargateApplication >> isServiceDiscoveryThroughConsulEnabled [

	^ self stargateConfiguration consulAgentLocation isEmpty not
]

{ #category : #'private - accessing' }
ConsulAwareStargateApplication >> operationsConfiguration [

	^ super operationsConfiguration
		  at: ConsulServiceDiscoveryPlugin endpoint put: self consulServiceDiscoveryConfiguration;
		  yourself
]

{ #category : #'private - accessing' }
ConsulAwareStargateApplication >> serviceDefinitions [

	^ self subclassResponsibility
]

{ #category : #'private - building' }
ConsulAwareStargateApplication >> serviceDiscoveryHealthCheckInterval [

	^ 10 seconds
]

{ #category : #'private - building' }
ConsulAwareStargateApplication >> serviceDiscoveryHealthCheckTimeout [

	^ 1 minute
]

{ #category : #'private - building' }
ConsulAwareStargateApplication >> withDockerHostnameDo: aFoundBlock ifAbsent: aNotFoundBlock [

	"Inside Docker containers the HOSTNAME variable holds the container id"

	^ OSEnvironment current at: 'HOSTNAME' ifPresent: aFoundBlock ifAbsent: aNotFoundBlock
]
