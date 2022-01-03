Class {
	#name : #StargateConsulExample,
	#superclass : #ConsulAwareStargateApplication,
	#category : #'Stargate-Consul-Examples'
}

{ #category : #private }
StargateConsulExample class >> applicationBaselineName [

	^ #BaselineOfStargateConsul
]

{ #category : #accessing }
StargateConsulExample class >> commandName [

	^ 'stargate-consul-example'
]

{ #category : #accessing }
StargateConsulExample class >> description [

	^ 'I provide a RESTful API over HTTP'
]

{ #category : #initialization }
StargateConsulExample class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : #'private - accessing' }
StargateConsulExample >> controllersToInstall [

	^ { StargateConsulEchoRESTfulController new }
]

{ #category : #'private - accessing' }
StargateConsulExample >> serviceDefinitions [

	^ { self buildServiceDefinitionNamed: 'echo' configuredBy: [  ] }
]
