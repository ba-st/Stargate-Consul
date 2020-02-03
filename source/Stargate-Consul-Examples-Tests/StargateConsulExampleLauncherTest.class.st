Class {
	#name : #StargateConsulExampleLauncherTest,
	#superclass : #TestCase,
	#category : #'Stargate-Consul-Examples-Tests'
}

{ #category : #tests }
StargateConsulExampleLauncherTest >> testActivate [

	| launcher |

	[ self
		shouldnt: [ launcher := StargateConsulExampleLauncher new
				commandLine:
					( CommandLineArguments
						withArguments: #('--public-URL=http://localhost' '--consul-agent-location=http://consul:8500' '--debug-mode') );
				disableConsulServiceDiscoveryPlugin;
				activate
			]
		raise: Exit
	]
		ensure: [ launcher stop ]
]

{ #category : #tests }
StargateConsulExampleLauncherTest >> testDescription [

	self assert: StargateConsulExampleLauncher description equals: 'I provide a RESTful API over HTTP'
]
