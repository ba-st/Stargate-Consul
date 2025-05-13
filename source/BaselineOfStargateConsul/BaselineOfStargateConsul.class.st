Class {
	#name : 'BaselineOfStargateConsul',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfStargateConsul',
	#package : 'BaselineOfStargateConsul'
}

{ #category : 'baselines' }
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
				group: 'Dependent-SUnit-Extensions' with: #('Stargate-SUnit' 'Launchpad-SUnit' 'Superluminal-SUnit');
				group: 'Development' with: #('Tests' 'Tools' 'Examples')
			]
]

{ #category : 'accessing' }
BaselineOfStargateConsul >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : 'baselines' }
BaselineOfStargateConsul >> setUpDependencies: spec [

	spec
		baseline: 'Stargate' with: [ spec repository: 'github://ba-st/Stargate:v10' ];
		project: 'Stargate-Deployment' copyFrom: 'Stargate' with: [ spec loads: 'Deployment' ];
		project: 'Stargate-SUnit' copyFrom: 'Stargate' with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'Stargate-Tools' copyFrom: 'Stargate' with: [ spec loads: 'Tools' ].

	spec
		baseline: 'Launchpad' with: [ spec repository: 'github://ba-st/Launchpad:v6' ];
		project: 'Launchpad-Deployment' copyFrom: 'Launchpad' with: [ spec loads: 'Deployment' ];
		project: 'Launchpad-SUnit' copyFrom: 'Launchpad' with: [ spec loads: 'Dependent-SUnit-Extensions' ].

	spec
		baseline: 'Superluminal' with: [ spec repository: 'github://ba-st/Superluminal:v6' ];
		project: 'Superluminal-API-Client' copyFrom: 'Superluminal' with: [ spec loads: 'API Client' ];
		project: 'Superluminal-SUnit' copyFrom: 'Superluminal' with: [ spec loads: 'Dependent-SUnit-Extensions' ];
]

{ #category : 'baselines' }
BaselineOfStargateConsul >> setUpPackages: spec [

	spec
		package: 'Stargate-Consul'
		with: [ spec requires: #( 'Stargate-Deployment' 'Superluminal-API-Client' ) ];
		group: 'Deployment' with: 'Stargate-Consul'.

	spec
		package: 'Stargate-Consul-Tests' with: [ spec requires: #( 'Stargate-Consul' 'Stargate-SUnit' ) ];
		group: 'Tests' with: 'Stargate-Consul-Tests'.

	spec
		package: 'Stargate-Consul-Examples'
		with: [ spec requires: #( 'Stargate-Consul' 'Launchpad-Deployment' ) ];
		group: 'Examples' with: 'Stargate-Consul-Examples'.

	spec
		package: 'Stargate-Consul-Examples-Tests'
		with: [ spec requires: #( 'Stargate-Consul-Examples' 'Stargate-SUnit' 'Launchpad-SUnit' ) ];
		group: 'Tests' with: 'Stargate-Consul-Examples-Tests'
]
