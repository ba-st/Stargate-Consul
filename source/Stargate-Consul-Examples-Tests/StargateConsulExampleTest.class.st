"
A StargateConsulExampleTest is a test class for testing the behavior of StargateConsulExample
"
Class {
	#name : #StargateConsulExampleTest,
	#superclass : #TestCase,
	#instVars : [
		'application',
		'port'
	],
	#category : #'Stargate-Consul-Examples-Tests'
}

{ #category : #running }
StargateConsulExampleTest >> runCase [

	self shouldnt: [ super runCase ] raise: Exit
]

{ #category : #running }
StargateConsulExampleTest >> setUp [

	super setUp.
	port := self freeListeningTCPPort.
	StargateConsulExample logsDirectory ensureCreateDirectory
]

{ #category : #running }
StargateConsulExampleTest >> start: aLaunchpadApplication withAll: arguments [

	String streamContents: [ :stream | 
		| context rootCommand |

		rootCommand := LaunchpadRootCommand new.
		context := LaunchpadCommandLineProcessingContext
			           handling: ( CommandLineArguments withArguments: { 
						             'launchpad'.
						             'start'.
						             aLaunchpadApplication commandName } , arguments )
			           writingTo: stream.
		self assert: ( rootCommand canHandle: ( context nextCommandLineArgumentIfNone: [ self fail ] ) ).
		rootCommand evaluateWithin: context.
		application := LaunchpadApplication currentlyRunning
		]
]

{ #category : #running }
StargateConsulExampleTest >> tearDown [

	application ifNotNil: [ application stop ].
	super tearDown
]

{ #category : #tests }
StargateConsulExampleTest >> testDefaultServiceDiscoveryTimeSlotBetweenRetries [

	self start: StargateConsulExample withAll: { 
			'--stargate.public-url=http://localhost:<1p>' expandMacrosWith: port.
			'--stargate.port=<1p>' expandMacrosWith: port.
			'--stargate.operations-secret=secret'.
			'--stargate.consul-agent-location=' }.

	self assert: application serviceDiscoveryTimeSlotBetweenRetries equals: 100 milliSeconds 
]

{ #category : #tests }
StargateConsulExampleTest >> testPrintHelpOn [

	| help |

	help := String streamContents: [ :stream | StargateConsulExample printHelpOn: stream ].

	self assert: help equals: ( 'NAME<r><t><t>stargate-consul-example [<1s>] - I provide a RESTful API over HTTP<r>SYNOPSYS<r><t><t>stargate-consul-example --stargate.public-url=%<publicURL%> --stargate.port=%<port%> --stargate.operations-secret=%<operationsSecret%> --stargate.consul-agent-location=%<consulAgentLocation%> [--stargate.scheme=%<scheme%>]<r>PARAMETERS<r><t><t>--stargate.public-url=%<publicURL%><r><t><t><t>Public URL where the API is deployed. Used to create hypermedia links.<r><t><t>--stargate.port=%<port%><r><t><t><t>Listening port.<r><t><t>--stargate.operations-secret=%<operationsSecret%><r><t><t><t>Secret key for checking JWT signatures.<r><t><t>--stargate.consul-agent-location=%<consulAgentLocation%><r><t><t><t>Location of the Consul Agent. Leave empty to disable the plugin.<r><t><t>--stargate.scheme=%<scheme%><r><t><t><t>Transport scheme. It''s used to configure Consul HTTP checks. Defaults to http.<r>ENVIRONMENT<r><t><t>STARGATE__PUBLIC_URL<r><t><t><t>Public URL where the API is deployed. Used to create hypermedia links.<r><t><t>STARGATE__PORT<r><t><t><t>Listening port.<r><t><t>STARGATE__OPERATIONS_SECRET<r><t><t><t>Secret key for checking JWT signatures.<r><t><t>STARGATE__CONSUL_AGENT_LOCATION<r><t><t><t>Location of the Consul Agent. Leave empty to disable the plugin.<r><t><t>STARGATE__SCHEME<r><t><t><t>Transport scheme. It''s used to configure Consul HTTP checks. Defaults to http.<r>' expandMacrosWith: StargateConsulExample version )
]

{ #category : #tests }
StargateConsulExampleTest >> testProjectName [

	self
		assert: StargateConsulExample projectName
		equals: 'Stargate-Consul'
]

{ #category : #tests }
StargateConsulExampleTest >> testStart [

	| response |

	self start: StargateConsulExample withAll: { 
			'--stargate.public-url=http://localhost:<1p>' expandMacrosWith: port.
			'--stargate.port=<1p>' expandMacrosWith: port.
			'--stargate.operations-secret=secret'.
			'--stargate.consul-agent-location=' }.

	response := ZnClient new
		            beOneShot;
		            enforceHttpSuccess: true;
		            get: application configuration stargate publicURL / 'echo' / 'hello'.

	self assert: response equals: 'HELLO'
]
