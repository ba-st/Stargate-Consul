Class {
	#name : #BaselineOfStargateConsul,
	#superclass : #BaselineOf,
	#category : #BaselineOfStargateConsul
}

{ #category : #baselines }
BaselineOfStargateConsul >> baseline: spec [

	<baseline>
	spec
		for: #pharo
		do: [ self
				setUpDependencies: spec;
				setUpPackages: spec.
			spec
				group: 'CI' with: 'Tests';
				group: 'Tools' with: #('Stargate-Tools');
				group: 'Development' with: #('Tests' 'Tools')
			]
]

{ #category : #accessing }
BaselineOfStargateConsul >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : #baselines }
BaselineOfStargateConsul >> setUpDependencies: spec [

	spec
		baseline: 'Stargate' with: [ spec repository: 'github://ba-st/Stargate:v4/source' ];
		project: 'Stargate-Core' copyFrom: 'Stargate' with: [ spec loads: 'Core' ];
		project: 'Stargate-SUnit' copyFrom: 'Stargate' with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'Stargate-Tools' copyFrom: 'Stargate' with: [ spec loads: 'Tools' ]
]

{ #category : #baselines }
BaselineOfStargateConsul >> setUpPackages: spec [

	spec
		package: 'Stargate-Consul' with: [ spec requires: #('Stargate-Core') ];
		group: 'Deployment' with: 'Stargate-Consul'.

	spec
		package: 'Stargate-Consul-Tests' with: [ spec requires: #('Stargate-Consul' 'Stargate-SUnit') ];
		group: 'Tests' with: 'Stargate-Consul-Tests'
]
