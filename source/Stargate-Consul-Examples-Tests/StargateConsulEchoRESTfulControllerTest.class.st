Class {
	#name : #StargateConsulEchoRESTfulControllerTest,
	#superclass : #SingleResourceRESTfulControllerTest,
	#category : #'Stargate-Consul-Examples-Tests'
}

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
