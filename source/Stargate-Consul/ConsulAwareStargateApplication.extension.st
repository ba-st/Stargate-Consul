Extension { #name : #ConsulAwareStargateApplication }

{ #category : #'*Stargate-Consul' }
ConsulAwareStargateApplication class >> stargateConfigurationParameters [

	^ super stargateConfigurationParameters , { MandatoryConfigurationParameter
		    named: 'Consul Agent Location'
		    describedBy: 'Location of the Consul Agent. Leave empty to disable the plugin'
		    inside: self sectionsForStargateConfiguration
		    convertingWith: #asUrl }
]
