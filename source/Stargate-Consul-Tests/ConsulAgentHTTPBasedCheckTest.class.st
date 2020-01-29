"
A ConsulAgentHTTPBasedCheckTest is a test class for testing the behavior of ConsulAgentHTTPBasedCheck
"
Class {
	#name : #ConsulAgentHTTPBasedCheckTest,
	#superclass : #TestCase,
	#category : #'Stargate-Consul-Tests'
}

{ #category : #tests }
ConsulAgentHTTPBasedCheckTest >> testAsJSON [

	| check json |

	check := ConsulAgentHTTPBasedCheck
		named: 'HTTP check'
		executing: #POST
		against: 'http://api.example.com' asUrl
		withHeaders: #()
		every: 10 seconds
		timeoutAfter: 1.5 minutes.

	json := NeoJSONObject fromString: ( NeoJSONWriter toStringPretty: check ).

	self
		assert: json Name equals: 'HTTP check';
		assert: json Method equals: 'POST';
		assert: json Header isEmpty;
		assert: json HTTP equals: 'http://api.example.com/';
		assert: json Timeout equals: '1m30s';
		assert: json Interval equals: '10s'
]

{ #category : #tests }
ConsulAgentHTTPBasedCheckTest >> testAsJSONWhenHeadersArePresent [

	| check json |

	check := ConsulAgentHTTPBasedCheck
		named: 'HTTP check'
		executing: #POST
		against: 'http://api.example.com' asUrl
		withHeaders: { #accept -> ZnMimeType applicationJson }
		every: 10 seconds
		timeoutAfter: 1.5 minutes.

	json := NeoJSONObject fromString: ( NeoJSONWriter toStringPretty: check ).

	self
		assert: json Name equals: 'HTTP check';
		assert: json Method equals: 'POST';
		assert: json Header accept equals: 'application/json';
		assert: json HTTP equals: 'http://api.example.com/';
		assert: json Timeout equals: '1m30s';
		assert: json Interval equals: '10s'
]

{ #category : #tests }
ConsulAgentHTTPBasedCheckTest >> testCantCreateUnnamed [

	self
		should: [ ConsulAgentHTTPBasedCheck
				named: ''
				executing: #POST
				against: 'http://api.example.com' asUrl
				withHeaders: #()
				every: 10 seconds
				timeoutAfter: 1.5 minutes
			]
		raise: InstanceCreationFailed
		withMessageText: 'A check name cannot be empty'
]

{ #category : #tests }
ConsulAgentHTTPBasedCheckTest >> testCantCreateWithNegativeDuration [

	self
		should: [ ConsulAgentHTTPBasedCheck
				named: 'xxx'
				executing: #POST
				against: 'http://api.example.com' asUrl
				withHeaders: #()
				every: -10 seconds
				timeoutAfter: 1.5 minutes
			]
		raise: InstanceCreationFailed
		withMessageText: 'The execution interval must be strictly positive'
]

{ #category : #tests }
ConsulAgentHTTPBasedCheckTest >> testCantCreateWithNegativeTimeout [

	self
		should: [ ConsulAgentHTTPBasedCheck
				named: 'xxx'
				executing: #POST
				against: 'http://api.example.com' asUrl
				withHeaders: #()
				every: 10 seconds
				timeoutAfter: -1 minutes
			]
		raise: InstanceCreationFailed
		withMessageText: 'The timeout must be strictly positive'
]

{ #category : #tests }
ConsulAgentHTTPBasedCheckTest >> testCantCreateWithZeroDuration [

	self
		should: [ ConsulAgentHTTPBasedCheck
				named: 'xxx'
				executing: #POST
				against: 'http://api.example.com' asUrl
				withHeaders: #()
				every: 0 seconds
				timeoutAfter: 1.5 minutes
			]
		raise: InstanceCreationFailed
		withMessageText: 'The execution interval must be strictly positive'
]

{ #category : #tests }
ConsulAgentHTTPBasedCheckTest >> testCantCreateWithZeroTimeout [

	self
		should: [ ConsulAgentHTTPBasedCheck
				named: 'xxx'
				executing: #POST
				against: 'http://api.example.com' asUrl
				withHeaders: #()
				every: 10 seconds
				timeoutAfter: 0 minutes
			]
		raise: InstanceCreationFailed
		withMessageText: 'The timeout must be strictly positive'
]
