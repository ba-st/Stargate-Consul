Class {
	#name : #StargateConsulEchoRESTfulControllerTest,
	#superclass : #SingleResourceRESTfulControllerTest,
	#category : #'Stargate-Consul-Examples-Tests'
}

{ #category : #'private - support' }
StargateConsulEchoRESTfulControllerTest >> baseUrl [

	^ 'http://api.example.com' asUrl
]

{ #category : #running }
StargateConsulEchoRESTfulControllerTest >> setUpResourceController [

	resourceController := StargateConsulEchoRESTfulController new
]

{ #category : #tests }
StargateConsulEchoRESTfulControllerTest >> testMessageText [

	| response |

	response := resourceController
		messageTextBasedOn: ( self requestToGETResourceIdentifiedBy: 'Hello' accepting: ZnMimeType textPlain )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contents equals: 'HELLO'
]
