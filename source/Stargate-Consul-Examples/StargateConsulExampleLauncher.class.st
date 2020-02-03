Class {
	#name : #StargateConsulExampleLauncher,
	#superclass : #ApplicationStarterCommandLineHandler,
	#instVars : [
		'api',
		'consulServiceDiscoveryIsEnabled'
	],
	#category : #'Stargate-Consul-Examples'
}

{ #category : #accessing }
StargateConsulExampleLauncher class >> commandName [

	^ 'stargate-consul-example'
]

{ #category : #accessing }
StargateConsulExampleLauncher class >> description [

	^ 'I provide a RESTful API over HTTP'
]

{ #category : #'private - accessing' }
StargateConsulExampleLauncher class >> logPrefix [

	^ 'stargate-consul-example'
]

{ #category : #'private - accessing' }
StargateConsulExampleLauncher >> apiConfiguration [

	^ Array
		with: #serverUrl -> self publicURL
		with: #port -> ( self configuration at: 'port' )
		with: #debugMode -> self isDebugModeEnabled
		with: #operations -> self operationsConfiguration
]

{ #category : #'private - accessing' }
StargateConsulExampleLauncher >> authAlgorithm [

	^ JWAHMACSHA256 parameterValue
]

{ #category : #'private - activation' }
StargateConsulExampleLauncher >> basicActivate [

	api := HTTPBasedRESTfulAPI
		configuredBy: self apiConfiguration
		installing: {StargateConsulEchoRESTfulController new}.

	CurrentLogger value
		logAsInfo: 'Installing API' during: [ api install ];
		logAsInfo: 'Starting API' during: [ api start ]
]

{ #category : #'private - accessing' }
StargateConsulExampleLauncher >> configurationDefinition [

	^ Array
		with: ( MandatoryArgument named: 'public-URL' convertingWith: #asUrl )
		with: ( OptionalArgument named: 'port' defaultingTo: 8080 convertingWith: #asNumber )
		with:
			( OptionalArgument named: 'operations-secret' defaultingTo: 'SECRET' convertingWith: #asByteArray )
				asSensitive
		with: ( MandatoryArgument named: 'consul-agent-location' convertingWith: #asUrl )
]

{ #category : #'private - accessing' }
StargateConsulExampleLauncher >> consulServiceDiscoveryConfiguration [

	^ Dictionary new
		at: #enabled put: consulServiceDiscoveryIsEnabled;
		at: #definitions
			put:
			{( ConsulServiceDefinitionBuilder new
				addCheck:
					( ConsulAgentHTTPBasedCheck
						named: 'health-check'
						executing: #POST
						against: self publicURL / 'operations' asUrl / HealthCheckPlugin endpoint
						withHeaders:
							{( #accept -> 'application/vnd.stargate.health-check.summary+json;version=1.0.0' ).
							( #authorization -> ( 'Bearer <1s>' expandMacrosWith: self healthCheckToken ) )}
						every: 10 seconds
						timeoutAfter: 1 minute );
				buildNamed: 'echo' )};
		at: #consulAgentLocation put: ( self configuration at: 'consul-agent-location' );
		yourself
]

{ #category : #configuring }
StargateConsulExampleLauncher >> disableConsulServiceDiscoveryPlugin [

	consulServiceDiscoveryIsEnabled := false
]

{ #category : #'private - accessing' }
StargateConsulExampleLauncher >> healthCheckToken [

	| jws |

	jws := JsonWebSignature new.
	jws algorithmName: self authAlgorithm.
	jws
		payload:
			( JWTClaimsSet new
				permissions: #('execute:health-check');
				yourself ).
	jws key: self operationsSecret.
	^ jws compactSerialized
]

{ #category : #initialization }
StargateConsulExampleLauncher >> initialize [

	super initialize.
	consulServiceDiscoveryIsEnabled := true
]

{ #category : #'private - accessing' }
StargateConsulExampleLauncher >> operationsConfiguration [

	^ Dictionary new
		at: #authSchema put: 'jwt';
		at: #authAlgorithm put: self authAlgorithm;
		at: #authSecret put: self operationsSecret;
		at: ConsulServiceDiscoveryPlugin endpoint put: self consulServiceDiscoveryConfiguration;
		yourself
]

{ #category : #'private - accessing' }
StargateConsulExampleLauncher >> operationsSecret [

	^ self configuration at: 'operations-secret'
]

{ #category : #'private - accessing' }
StargateConsulExampleLauncher >> publicURL [

	^ self configuration at: 'public-URL'
]

{ #category : #'private - activation' }
StargateConsulExampleLauncher >> stop [

	api ifNotNil: [ :theAPI | theAPI stop ]
]
