Class {
	#name : #StargateConsulEchoRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'requestHandler'
	],
	#category : #'Stargate-Consul-Examples'
}

{ #category : #routes }
StargateConsulEchoRESTfulController >> declareGetMessageRoute [

	^ RouteSpecification
		handling: #GET
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self messageTextBasedOn: httpRequest within: requestContext ]
]

{ #category : #initialization }
StargateConsulEchoRESTfulController >> initialize [

	super initialize.
	requestHandler := RESTfulRequestHandlerBuilder new
		handling: 'echo' extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		whenResponding: ZnMimeType textPlain encodeApplying: [ :resource | resource ];
		createEntityTagHashingEncodedResource;
		build
]

{ #category : #API }
StargateConsulEchoRESTfulController >> messageTextBasedOn: httpRequest within: requestContext [

	^ requestHandler
		from: httpRequest
		within: requestContext
		get: [ :message | message asString asUppercase ]
]

{ #category : #private }
StargateConsulEchoRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
StargateConsulEchoRESTfulController >> typeIdConstraint [

	^ IsObject
]
