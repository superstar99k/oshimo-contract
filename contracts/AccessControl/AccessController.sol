//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract AccessController is AccessControl {
	constructor() {
		_setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
		_setRoleAdmin(DEFAULT_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
	}

	function setupRole(bytes32 role, address account) public {
		require(
			hasRole(role, _msgSender()) ||
				hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
			"no access permission"
		);
		_setupRole(role, account);
	}

	function bulkSetupRole(bytes32[] memory roles, address account) public {
		for (uint256 i; i < roles.length; i++) {
			setupRole(roles[i], account);
		}
	}

	function revokeRole(bytes32 role, address account) public override {
		super.revokeRole(role, account);
	}

	function bulkRevokeRole(bytes32[] memory roles, address account) public {
		for (uint256 i; i < roles.length; i++) {
			revokeRole(roles[i], account);
		}
	}

	function setRoleAdmin(
		bytes32 roleId,
		bytes32 adminRoleId
	) public onlyRole(DEFAULT_ADMIN_ROLE) {
		_setRoleAdmin(roleId, adminRoleId);
	}
}
