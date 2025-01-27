"
I'm a kind of Consul Agent health check depending on performing an HTTP request.
"
Class {
	#name : 'ConsulAgentHTTPBasedCheck',
	#superclass : 'ConsulAgentCheck',
	#instVars : [
		'name',
		'url',
		'method',
		'headers',
		'timeout',
		'invocationInterval',
		'deregistrationTimeout'
	],
	#category : 'Stargate-Consul',
	#package : 'Stargate-Consul'
}

{ #category : 'private - testing' }
ConsulAgentHTTPBasedCheck class >> isStrictlyPositive: aDuration [

  ^ aDuration positive and: [ aDuration isZero not ]
]

{ #category : 'instance creation' }
ConsulAgentHTTPBasedCheck class >> named: aName executing: anHttpMethod against: anUrl withHeaders: aHeaderCollection every: aDuration timeoutAfter: timeoutDuration deregisteringAfterStatusCriticalFor: aTimeoutDurationUntilDeregistration [

  AssertionCheckerBuilder new
    raising: InstanceCreationFailed;
    checking: [ :asserter |
        asserter
          enforce: [ aName notEmpty ] because: 'The check name cannot be empty';
          enforce: [ self isStrictlyPositive: aDuration ]
          because: 'The execution interval must be strictly positive';
          enforce: [ self isStrictlyPositive: timeoutDuration ]
          because: 'The timeout must be strictly positive';
          enforce: [ self isStrictlyPositive: aTimeoutDurationUntilDeregistration ]
          because: 'The deregistration timeout must be strictly positive'
      ];
    buildAndCheck.

  ^ self new
      initializeNamed: aName
      executing: anHttpMethod
      against: anUrl asUrl
      withHeaders: aHeaderCollection
      every: aDuration
      timeoutAfter: timeoutDuration
      deregisteringAfterStatusCriticalFor: aTimeoutDurationUntilDeregistration
]

{ #category : 'converting' }
ConsulAgentHTTPBasedCheck >> asDictionary [

	^ super asDictionary
		at: 'HTTP' put: url;
		at: 'Method' put: method;
		at: 'Header' put: headers;
		at: 'Timeout' put: ( self asGoTimeFormat: timeout );
		at: 'deregister_critical_service_after' put: (self asGoTimeFormat: deregistrationTimeout);
		yourself
]

{ #category : 'initialization' }
ConsulAgentHTTPBasedCheck >> initializeHeadersBasedOn: aHeaderCollection [

	"Consul expects an array of strings as values for the headers.	"

	headers := Dictionary new.
	aHeaderCollection asDictionary
		keysAndValuesDo: [ :headerName :headerValue | 
			headers
				at: headerName
				put:
					( headerValue isArray
						ifTrue: [ headerValue ]
						ifFalse: [ Array with: headerValue ] )
			]
]

{ #category : 'initialization' }
ConsulAgentHTTPBasedCheck >> initializeNamed: aName executing: anHttpMethod against: anUrl withHeaders: aHeaderCollection every: aDuration timeoutAfter: timeoutDuration deregisteringAfterStatusCriticalFor: aTimeoutDurationUntilDeregistration [

  name := aName.
  method := anHttpMethod.
  url := anUrl.
  self initializeHeadersBasedOn: aHeaderCollection.
  invocationInterval := aDuration.
  timeout := timeoutDuration.
  deregistrationTimeout := aTimeoutDurationUntilDeregistration
]

{ #category : 'accessing' }
ConsulAgentHTTPBasedCheck >> invocationInterval [

	^ invocationInterval
]

{ #category : 'accessing' }
ConsulAgentHTTPBasedCheck >> name [

	^ name
]

{ #category : 'encoding' }
ConsulAgentHTTPBasedCheck >> neoJsonOn: neoJSONWriter [

	( neoJSONWriter customMappingFor: ZnMimeType ) encoder: [ :mediaType | mediaType asString ].
	( neoJSONWriter customMappingFor: ZnUrl ) encoder: [ :theUrl | theUrl asString ].
	super neoJsonOn: neoJSONWriter 
]
