"
A ConsulAgentCheckTest is a test class for testing the behavior of ConsulAgentCheck
"
Class {
	#name : #ConsulAgentCheckTest,
	#superclass : #TestCase,
	#category : #'Stargate-Consul-Tests'
}

{ #category : #test }
ConsulAgentCheckTest >> testAsGoTimeFormat [

	self
		assert: ( ConsulAgentCheck new asGoTimeFormat: 1.5644648441 hours )
		equals: '1h33m52s73ms438us760ns'
]
