"
A ConsulServiceDefinitionBuilderTest is a test class for testing the behavior of ConsulServiceDefinitionBuilder
"
Class {
	#name : #ConsulServiceDefinitionBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'builder'
	],
	#category : #'Stargate-Consul-Tests'
}

{ #category : #'private - asserting' }
ConsulServiceDefinitionBuilderTest >> assertDefinition: aServiceDefinition jsonEquals: aJSONString [

	self
		assert: ( NeoJSONObject fromString: ( NeoJSONWriter toString: aServiceDefinition ) )
		equals: ( NeoJSONObject fromString: aJSONString )
]

{ #category : #'private - asserting' }
ConsulServiceDefinitionBuilderTest >> assertNameIn: definition equals: aString [

	self assert: definition Name equals: aString
]

{ #category : #running }
ConsulServiceDefinitionBuilderTest >> setUp [

	super setUp.
	builder := ConsulServiceDefinitionBuilder new
]

{ #category : #tests }
ConsulServiceDefinitionBuilderTest >> testEnableTagOverride [

	| definition |

	definition := builder
		enableTagOverride;
		buildNamed: 'redis'.

	self
		assertNameIn: definition equals: 'redis';
		assertDefinition: definition jsonEquals: '{"Name":"redis","EnableTagOverride":true}'
]

{ #category : #tests }
ConsulServiceDefinitionBuilderTest >> testServiceWithMetadata [

	| definition |

	definition := builder
		metadataAt: 'version' put: '1.2.5';
		metadataAt: 'author' put: 'anonymous';
		buildNamed: 'redis'.

	self
		assertNameIn: definition equals: 'redis';
		assertDefinition: definition
			jsonEquals: '{"Name":"redis","Meta":{"version":"1.2.5","author":"anonymous"}}'
]

{ #category : #tests }
ConsulServiceDefinitionBuilderTest >> testServiceWithOnlyOneCheck [

	| definition |

	definition := builder
		addCheck:
			( ConsulAgentDockerBasedCheck
				named: 'check'
				executing: '/bin/bash'
				withArguments: #('true')
				inContainer: 'xxx'
				every: 1 milliSecond );
		buildNamed: 'redis'.

	self
		assertNameIn: definition equals: 'redis';
		assertDefinition: definition
			jsonEquals:
			'{"Name":"redis","Checks":[{"Name":"check","Shell":"/bin/bash","Args":["true"],"DockerContainerID":"xxx","Interval":"1ms"}]}'
]

{ #category : #tests }
ConsulServiceDefinitionBuilderTest >> testServiceWithSeveralChecks [

	| definition |

	definition := builder
		addCheck:
			( ConsulAgentDockerBasedCheck
				named: 'check'
				executing: '/bin/bash'
				withArguments: #('true')
				inContainer: 'xxx'
				every: 1 milliSecond );
		addCheck:
			( ConsulAgentHTTPBasedCheck
				named: 'ping'
				executing: #GET
				against: 'https://api.example.com'
				withHeaders: #()
				every: 100 milliSeconds
				timeoutAfter: 1 minute );
		buildNamed: 'redis'.

	self
		assertNameIn: definition equals: 'redis';
		assertDefinition: definition
			jsonEquals:
			'{
				"Name":"redis",
				"Checks":[
					{"Name":"check","Shell":"/bin/bash","Args":["true"],"DockerContainerID":"xxx","Interval":"1ms"},
					{"Name":"ping","HTTP":"https://api.example.com/","Method":"GET","Header":{},"Interval":"100ms","Timeout":"1m"}
				]
			}'
]

{ #category : #tests }
ConsulServiceDefinitionBuilderTest >> testServiceWithTaggedAddresses [

	| definition |

	definition := builder
		addAsLANAddress: '127.0.0.0';
		addAsWANAddress: '198.18.0.53' at: 80;
		buildNamed: 'redis'.

	self
		assertNameIn: definition equals: 'redis';
		assertDefinition: definition
			jsonEquals:
			'{"Name":"redis","TaggedAddresses":{"lan":{"address":"127.0.0.0"},"wan":{"address":"198.18.0.53","port":80}}}'
]

{ #category : #tests }
ConsulServiceDefinitionBuilderTest >> testSimpleServiceCreation [

	| definition |

	definition := builder
		identifiedBy: 'redis1';
		servedAtLocalhost;
		addTag: 'primary';
		addTag: 'cache';
		port: 8800;
		buildNamed: 'redis'.

	self
		assertNameIn: definition equals: 'redis';
		assert: definition ID equals: 'redis1';
		assert: definition Address equals: 'localhost';
		assert: definition Port equals: 8800;
		assertDefinition: definition
			jsonEquals: '{"Name":"redis","ID":"redis1","Address":"localhost","Tags":["primary","cache"],"Port":8800}'
]

{ #category : #tests }
ConsulServiceDefinitionBuilderTest >> testSimplestServiceCreation [

	| definition |

	definition := builder buildNamed: 'redis'.

	self
		assertNameIn: definition equals: 'redis';
		assertDefinition: definition jsonEquals: '{"Name":"redis"}'
]
