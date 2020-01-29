"
I'm a kind of Consul Agent health check depending on invoking an external application which is packaged within a Docker Container. 

The application is triggered within the running container via the Docker Exec API. We expect that the Consul agent user has access to either the Docker HTTP API or the unix socket. 
Consul uses $DOCKER_HOST to determine the Docker API endpoint. The application is expected to run, perform a health check of the service running inside the container, and exit with an appropriate exit code. The check should be paired with an invocation interval. The shell on which the check has to be performed is configurable which makes it possible to run containers which have different shells on the same host. Check output for Docker is limited to 4KB. Any output larger than this will be truncated. 
"
Class {
	#name : #ConsulAgentDockerBasedCheck,
	#superclass : #ConsulAgentCheck,
	#instVars : [
		'name',
		'shell',
		'arguments',
		'containerId',
		'invokationInterval'
	],
	#category : #'Stargate-Consul'
}

{ #category : #'instance creation' }
ConsulAgentDockerBasedCheck class >> named: aName executing: aCommand withArguments: anArgumentArray inContainer: aContainerId every: aDuration [

	AssertionCheckerBuilder new
		raising: InstanceCreationFailed;
		checking: [ :asserter | 
			asserter
				enforce: [ aName notEmpty ] because: 'A check name cannot be empty';
				enforce: [ aCommand notEmpty ] because: 'A command cannot be empty';
				enforce: [ aContainerId notEmpty ] because: 'The target container id cannot be empty';
				enforce: [ aDuration positive and: [ aDuration isZero not ] ]
					because: 'The execution interval must be strictly positive'
			];
		buildAndCheck.

	^ self new
		initializeNamed: aName
		executing: aCommand
		withArguments: anArgumentArray
		inContainer: aContainerId
		every: aDuration
]

{ #category : #converting }
ConsulAgentDockerBasedCheck >> asDictionary [

	^ super asDictionary
		at: 'DockerContainerID' put: containerId;
		at: 'Shell' put: shell;
		at: 'Args' put: arguments;
		yourself
]

{ #category : #initialization }
ConsulAgentDockerBasedCheck >> initializeNamed: aName executing: aCommand withArguments: anArgumentArray inContainer: aContainerId every: aDuration [

	name := aName.
	shell := aCommand.
	arguments := anArgumentArray.
	containerId := aContainerId.
	invokationInterval := aDuration
]

{ #category : #accessing }
ConsulAgentDockerBasedCheck >> invokationInterval [

	^ invokationInterval
]

{ #category : #accessing }
ConsulAgentDockerBasedCheck >> name [

	^ name
]
