| branchName |

branchName := Smalltalk os environment at: 'TRAVIS_BRANCH' ifAbsent: ['release-candidate'].
branchName ifEmpty: [ branchName := 'release-candidate'].

Metacello new
	baseline: 'StargateConsul';
	repository: ('github://ba-st/Stargate-Consul:<1s>/source' expandMacrosWith: branchName);
	load: 'Examples'.
