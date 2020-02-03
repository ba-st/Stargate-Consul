| branchName |

branchName := Smalltalk os environment at: 'TRAVIS_BRANCH' ifAbsent: ['release-candidate'].
branchName ifEmpty: [ branchName := 'release-candidate'].

Metacello new
	baseline: 'StargateConsul';
	repository: 'github://ba-st/Stargate-Consul:release-candidate/source';
	load: 'Examples'.
