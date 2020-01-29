"
I'm a builder intended to simplify the creation of service definitions under the Consult umbrella (See https://www.consul.io/docs/agent/services.html for details)
"
Class {
	#name : #ConsulServiceDefinitionBuilder,
	#superclass : #Object,
	#instVars : [
		'serviceDefinition'
	],
	#category : #'Stargate-Consul'
}

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> addAsLANAddress: aString [

	self taggedAddressesAt: 'lan' on: 'address' put: aString
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> addAsLANAddress: aString at: aPortNumber [

	self
		addAsLANAddress: aString;
		assertIsValidPort: aPortNumber;
		taggedAddressesAt: 'lan' on: 'port' put: aPortNumber
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> addAsWANAddress: aString [

	self taggedAddressesAt: 'wan' on: 'address' put: aString
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> addAsWANAddress: aString at: aPortNumber [

	self
		addAsWANAddress: aString;
		assertIsValidPort: aPortNumber;
		taggedAddressesAt: 'wan' on: 'port' put: aPortNumber
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> addTag: aString [

	| tags |

	AssertionChecker enforce: [ aString notEmpty ] because: 'A tag cannot be empty'.
	tags := serviceDefinition at: 'Tags' ifAbsentPut: [ OrderedCollection new ].
	tags add: aString
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> address: aString [ 
	
	serviceDefinition at: 'Address' put: aString
]

{ #category : #private }
ConsulServiceDefinitionBuilder >> assertIsValidPort: aPortNumber [

	AssertionChecker
		enforce: [ aPortNumber isInteger and: [ aPortNumber positive ] ]
		because: 'A port cannot be a negative number'
]

{ #category : #building }
ConsulServiceDefinitionBuilder >> buildNamed: aServiceName [

	AssertionChecker enforce: [ aServiceName notEmpty ] because: 'A service name cannot be empty'.
	serviceDefinition at: 'Name' put: aServiceName.
	^ NeoJSONObject newFrom: serviceDefinition
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> enableTagOverride [

	serviceDefinition at: 'EnableTagOverride' put: true
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> identifiedBy: aString [

	AssertionChecker enforce: [ aString notEmpty ] because: 'An ID cannot be empty'.
	serviceDefinition at: 'ID' put: aString
]

{ #category : #initialization }
ConsulServiceDefinitionBuilder >> initialize [ 
	
	super initialize .
	serviceDefinition := OrderedDictionary new
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> metadataAt: aKey put: aValue [

	serviceDefinition at: 'Meta' at: aKey put: aValue
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> port: anInteger [

	self assertIsValidPort: anInteger.
	serviceDefinition at: 'Port' put: anInteger
]

{ #category : #configuring }
ConsulServiceDefinitionBuilder >> servedAtLocalhost [

	self address: 'localhost'
]

{ #category : #private }
ConsulServiceDefinitionBuilder >> taggedAddressesAt: aTag on: aKey put: aValue [

	| taggedAddresses |

	taggedAddresses := serviceDefinition
		at: 'TaggedAddresses'
		ifAbsentPut: [ serviceDefinition species new ].
	taggedAddresses at: aTag at: aKey put: aValue
]
