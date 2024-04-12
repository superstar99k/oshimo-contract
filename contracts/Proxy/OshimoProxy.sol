// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract OshimoProxy is ERC1967Proxy {
	constructor(
		address _logic,
		bytes memory _data
	) ERC1967Proxy(_logic, _data) {}

	function upgradeImplementation(address _impl) public {
		_upgradeTo(_impl);
	}
}
