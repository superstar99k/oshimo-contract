//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract AccessControlRegistry is Context {
	uint16 public version;
	mapping(uint16 => AccessControl) public accessController;

	event AccessControlUpdated(
		uint16 indexed version,
		AccessControl indexed accessController
	);

	modifier onlyPermited(bytes32 role) {
		require(
			accessController[version].hasRole(role, _msgSender()),
			"no access permission"
		);
		_;
	}

	constructor(AccessControl _accessControler) {
		accessController[version] = _accessControler;
	}

	function _setAccessControler(
		AccessControl newaccessControler
	) internal virtual {
		version++;
		accessController[version] = newaccessControler;
		emit AccessControlUpdated(version, newaccessControler);
	}
}
