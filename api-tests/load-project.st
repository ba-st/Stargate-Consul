| branchName |

branchName := Smalltalk os environment at: 'TRAVIS_BRANCH' ifAbsent: [Error signal: 'TRAVIS_BRANCH environment variable not set'].
branchName ifEmpty: [ Error signal: 'TRAVIS_BRANCH environment variable value is empty'].

Metacello new
	baseline: 'StargateConsul';
	repository: ('github://ba-st/Stargate-Consul:<1s>/source' expandMacrosWith: branchName);
	load: 'Examples'.
