| branchName |

branchName := Smalltalk os environment at: 'BRANCH_NAME' ifAbsent: [Error signal: 'BRANCH_NAME environment variable not set'].
branchName ifEmpty: [ Error signal: 'BRANCH_NAME environment variable value is empty'].

Metacello new
	baseline: 'StargateConsul';
	repository: ('github://ba-st/Stargate-Consul:<1s>/source' expandMacrosWith: branchName);
	load: 'Examples'.
