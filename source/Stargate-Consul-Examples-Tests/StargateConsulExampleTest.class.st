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

	application ifNotNil: #stop.
	super tearDown
]

{ #category : #tests }
StargateConsulExampleTest >> testPrintHelpOn [

	| help |

	help := String streamContents: [ :stream | StargateConsulExample printHelpOn: stream ].

	self assert: help equals: ( 'NAME
		stargate-consul-example [<1s>] - I provide a RESTful API over HTTP
SYNOPSYS
		stargate-consul-example --stargate.public-url=%<publicURL%> --stargate.port=%<port%> --stargate.operations-secret=%<operationsSecret%> --stargate.consul-agent-location=%<consulAgentLocation%>
PARAMETERS
		--stargate.public-url=%<publicURL%>
			Public URL where the API is deployed. Used to create hypermedia links.
		--stargate.port=%<port%>
			Listening port.
		--stargate.operations-secret=%<operationsSecret%>
			Secret key for checking JWT signatures.
		--stargate.consul-agent-location=%<consulAgentLocation%>
			Location of the Consul Agent. Leave empty to disable the plugin.
ENVIRONMENT
		STARGATE__PUBLIC_URL
			Public URL where the API is deployed. Used to create hypermedia links.
		STARGATE__PORT
			Listening port.
		STARGATE__OPERATIONS_SECRET
			Secret key for checking JWT signatures.
		STARGATE__CONSUL_AGENT_LOCATION
			Location of the Consul Agent. Leave empty to disable the plugin.
' expandMacrosWith: StargateConsulExample version )
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
