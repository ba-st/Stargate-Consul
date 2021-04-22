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
				group: 'Development' with: #('Tests' 'Tools' 'Examples')
			]
]

{ #category : #accessing }
BaselineOfStargateConsul >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : #baselines }
BaselineOfStargateConsul >> setUpDependencies: spec [

	spec
		baseline: 'Stargate' with: [ spec repository: 'github://ba-st/Stargate:v6' ];
		project: 'Stargate-Core' copyFrom: 'Stargate' with: [ spec loads: 'Core' ];
		project: 'Stargate-HealthCheck-Deployment'
			copyFrom: 'Stargate'
			with: [ spec loads: 'HealthCheck' ];
		project: 'Stargate-SUnit' copyFrom: 'Stargate' with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'Stargate-Tools' copyFrom: 'Stargate' with: [ spec loads: 'Tools' ].

	spec
		baseline: 'Launchpad' with: [ spec repository: 'github://ba-st/Launchpad:v3' ];
		project: 'Launchpad-Deployment' copyFrom: 'Launchpad' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'Superluminal' with: [ spec repository: 'github://ba-st/Superluminal:v2' ];
		project: 'Superluminal-Core' copyFrom: 'Superluminal' with: [ spec loads: 'Core' ]
]

{ #category : #baselines }
BaselineOfStargateConsul >> setUpPackages: spec [

	spec
		package: 'Stargate-Consul' with: [ spec requires: #('Stargate-Core' 'Superluminal-Core') ];
		group: 'Deployment' with: 'Stargate-Consul'.

	spec
		package: 'Stargate-Consul-Tests' with: [ spec requires: #('Stargate-Consul' 'Stargate-SUnit') ];
		group: 'Tests' with: 'Stargate-Consul-Tests'.

	spec
		package: 'Stargate-Consul-Examples'
			with: [ spec requires: #('Stargate-Consul' 'Launchpad-Deployment' 'Stargate-HealthCheck-Deployment') ];
		group: 'Examples' with: 'Stargate-Consul-Examples'.

	spec
		package: 'Stargate-Consul-Examples-Tests'
			with: [ spec requires: #('Stargate-Consul-Examples' 'Stargate-SUnit') ];
		group: 'Tests' with: 'Stargate-Consul-Examples-Tests'
]
