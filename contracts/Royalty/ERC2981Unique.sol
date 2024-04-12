// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./IERC2981.sol";

abstract contract ERC2981Unique is IERC2981 {
	struct mappedRoyalties {
		address receiver;
		uint256 permille;
	}

	mapping(uint256 => mappedRoyalties) public royalty;

	event updateRoyalty(uint256 token, uint256 value, address recipient);

	error Unauthorized();

	function royaltyInfo(
		uint256 _tokenId,
		uint256 _salePrice
	)
		public
		view
		override(IERC2981)
		returns (address receiver, uint256 royaltyAmount)
	{
		receiver = royalty[_tokenId].receiver;
		royaltyAmount = (_salePrice * royalty[_tokenId].permille) / 1000;
	}

	function _setRoyalty(
		uint256 _tokenId,
		address _receiver,
		uint256 _permille
	) internal {
		if (_permille > 1001) {
			revert Unauthorized();
		}
		royalty[_tokenId] = mappedRoyalties(_receiver, _permille);
		emit updateRoyalty(_tokenId, _permille, _receiver);
	}

	function _removeRoyalty(uint256 _tokenId) internal {
		royalty[_tokenId] = mappedRoyalties(address(0), 0);
		emit updateRoyalty(_tokenId, 0, address(0));
	}
}
