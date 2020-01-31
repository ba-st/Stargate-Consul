"
A ConsulAgentDockerBasedCheckTest is a test class for testing the behavior of ConsulAgentDockerBasedCheck
"
Class {
	#name : #ConsulAgentDockerBasedCheckTest,
	#superclass : #TestCase,
	#category : #'Stargate-Consul-Tests'
}

{ #category : #tests }
ConsulAgentDockerBasedCheckTest >> testAsJSON [

	| check json |

	check := ConsulAgentDockerBasedCheck
		named: 'Check memory'
		executing: '/bin/bash'
		withArguments: #('/usr/local/bin/check-memory.sh')
		inContainer: 'f972c95ebf0e'
		every: 10 seconds.

	json := NeoJSONObject fromString: ( NeoJSONWriter toStringPretty: check ).

	self
		assert: json Name equals: 'Check memory';
		assert: json Shell equals: '/bin/bash';
		assert: json Args equals: #('/usr/local/bin/check-memory.sh');
		assert: json DockerContainerID equals: 'f972c95ebf0e';
		assert: json Interval equals: '10s'
]

{ #category : #tests }
ConsulAgentDockerBasedCheckTest >> testCantCreateUnnamed [

	self
		should: [ ConsulAgentDockerBasedCheck
				named: ''
				executing: '/bin/bash'
				withArguments: #('/usr/local/bin/check-memory.sh')
				inContainer: 'f972c95ebf0e'
				every: 10 seconds
			]
		raise: InstanceCreationFailed
		withMessageText: 'The check name cannot be empty'
]

{ #category : #tests }
ConsulAgentDockerBasedCheckTest >> testCantCreateWhenShellCommandIsMissing [

	self
		should: [ ConsulAgentDockerBasedCheck
				named: 'xxx'
				executing: ''
				withArguments: #('/usr/local/bin/check-memory.sh')
				inContainer: 'f972c95ebf0e'
				every: 10 seconds
			]
		raise: InstanceCreationFailed
		withMessageText: 'The command to execute cannot be empty'
]

{ #category : #tests }
ConsulAgentDockerBasedCheckTest >> testCantCreateWithEmptyContainerId [

	self
		should: [ ConsulAgentDockerBasedCheck
				named: 'xx'
				executing: '/bin/bash'
				withArguments: #('/usr/local/bin/check-memory.sh')
				inContainer: ''
				every: 10 seconds
			]
		raise: InstanceCreationFailed
		withMessageText: 'The target container id cannot be empty'
]

{ #category : #tests }
ConsulAgentDockerBasedCheckTest >> testCantCreateWithNegativeDuration [

	self
		should: [ ConsulAgentDockerBasedCheck
				named: 'xx'
				executing: '/bin/bash'
				withArguments: #('/usr/local/bin/check-memory.sh')
				inContainer: 'f972c95ebf0e'
				every: -10 seconds
			]
		raise: InstanceCreationFailed
		withMessageText: 'The execution interval must be strictly positive'
]

{ #category : #tests }
ConsulAgentDockerBasedCheckTest >> testCantCreateWithZeroDuration [

	self
		should: [ ConsulAgentDockerBasedCheck
				named: 'xx'
				executing: '/bin/bash'
				withArguments: #('/usr/local/bin/check-memory.sh')
				inContainer: 'f972c95ebf0e'
				every: 0 seconds
			]
		raise: InstanceCreationFailed
		withMessageText: 'The execution interval must be strictly positive'
]
