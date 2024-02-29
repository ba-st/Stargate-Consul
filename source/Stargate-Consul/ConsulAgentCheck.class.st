"
I represent an application-level health check to be performed by a Consul agent and associated with a service.
There are several checks represented by my subclasses.
"
Class {
	#name : #ConsulAgentCheck,
	#superclass : #Object,
	#category : #'Stargate-Consul'
}

{ #category : #converting }
ConsulAgentCheck >> asDictionary [

	^ Dictionary new
		at: 'Name' put: self name;
		at: 'Interval' put: ( self asGoTimeFormat: self invocationInterval );
		yourself
]

{ #category : #private }
ConsulAgentCheck >> asGoTimeFormat: aDuration [

	"A duration string is a possibly signed sequence of decimal numbers, each with optional fraction and a unit suffix, such as 300ms, -1.5h or 2h45m.
	Valid time units are ns, us (or µs), ms, s, m, h."

	^ String
		streamContents: [ :stream | 
			self
				nextPut: aDuration hours of: 'h' in: stream;
				nextPut: aDuration minutes of: 'm' in: stream;
				nextPut: aDuration asSeconds of: 's' in: stream;
				nextPut: aDuration wholeMilliseconds of: 'ms' in: stream;
				nextPut: aDuration wholeMicroseconds of: 'us' in: stream;
				nextPut: aDuration wholeNanoseconds of: 'ns' in: stream
			]
]

{ #category : #accessing }
ConsulAgentCheck >> invocationInterval [

	^ self subclassResponsibility
]

{ #category : #accessing }
ConsulAgentCheck >> name [

	^ self subclassResponsibility
]

{ #category : #encoding }
ConsulAgentCheck >> neoJsonOn: neoJSONWriter [

	neoJSONWriter writeMap: self asDictionary
]

{ #category : #private }
ConsulAgentCheck >> nextPut: aNumber of: aTimeUnitString in: stream [

	aNumber strictlyPositive
		then: [ stream
				nextPutAll: aNumber asString;
				nextPutAll: aTimeUnitString
			]
]
