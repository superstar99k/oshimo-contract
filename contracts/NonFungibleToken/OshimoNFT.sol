//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "../AccessControl/AccessControlRegistry.sol";
import "../Marketplace/OshimoMarketplace.sol";

contract OshimoNFT is
	ERC721,
	ERC721URIStorage,
	ERC721Burnable,
	AccessControlRegistry
{
	using Counters for Counters.Counter;
	Counters.Counter private _tokenUuids;
	Counters.Counter private _tokensSold;

	OshimoMarketplace public marketplace;
	string baseURI;
	bool public revealed = false;
	string public baseExtension = ".json";

	bytes32 public constant NFT_ACCESS_ROLE = keccak256("NFT_ACCESS_ROLE");
	bytes32 public constant NFT_MINTER_ROLE = keccak256("NFT_MINTER_ROLE");

	constructor(
		AccessControl _accessControler,
		string memory name_,
		string memory symbol_,
		OshimoMarketplace marketplace_,
		string memory initbaseURI
	) ERC721(name_, symbol_) AccessControlRegistry(_accessControler) {
		marketplace = marketplace_;
		setBaseURI(initbaseURI);
	}

	struct BulkMintArg {
		address to;
		string tokenUri;
	}

	function safeMintBulk(
		BulkMintArg[] memory bulkMintArg
	) external onlyPermited(NFT_MINTER_ROLE) {
		for (uint256 i; i < bulkMintArg.length; i++) {
			uint256 tokenId = _takeTokenID();
			_safeMint(bulkMintArg[i].to, tokenId);
			_setTokenURI(tokenId, bulkMintArg[i].tokenUri);
		}
	}

	function setAccessControler(
		AccessControl newaccessControler
	) public onlyPermited(NFT_ACCESS_ROLE) {
		_setAccessControler(newaccessControler);
	}

	function safeMint(
		address to,
		string memory tokenUri
	) external onlyPermited(NFT_MINTER_ROLE) {
		uint256 tokenId = _takeTokenID();
		_safeMint(to, tokenId);

		_setTokenURI(tokenId, tokenUri);
	}

	function lazyMint(
		string memory tokenUri,
		uint256 price,
		address receiver,
		uint256 percentage
	) external onlyPermited(NFT_MINTER_ROLE) returns (uint256) {
		uint256 tokenId = _takeTokenID();
		_safeMint(address(marketplace), tokenId);
		_setTokenURI(tokenId, tokenUri);

		setApprovalForAll(address(marketplace), true);

		marketplace.list(address(this), tokenId, price, receiver, percentage);
		return tokenId;
	}

	function _baseURI() internal view virtual override returns (string memory) {
		return baseURI;
	}

	function exists(uint256 tokenId) public view returns (bool) {
		return _exists(tokenId);
	}

	function _takeTokenID() internal returns (uint256) {
		_tokenUuids.increment();
		return _tokenUuids.current();
	}

	function nextTokenID() public view returns (uint256) {
		return _tokenUuids.current() + 1;
	}

	function tokenURI(
		uint256 tokenId
	)
		public
		view
		virtual
		override(ERC721, ERC721URIStorage)
		returns (string memory)
	{
		require(
			_exists(tokenId),
			"ERC721Metadata: URI query for nonexistent token"
		);

		if (revealed == false) {
			super.tokenURI(tokenId);
		}

		string memory currentBaseURI = _baseURI();
		return
			bytes(currentBaseURI).length > 0
				? string(
					abi.encodePacked(
						currentBaseURI,
						Strings.toString(tokenId),
						baseExtension
					)
				)
				: "";
	}

	function reveal() public onlyPermited(NFT_MINTER_ROLE) {
		revealed = true;
	}

	function _burn(
		uint256 tokenId
	) internal virtual override(ERC721, ERC721URIStorage) {
		super._burn(tokenId);
	}

	function setBaseURI(string memory _newBaseURI) public {
		baseURI = _newBaseURI;
	}
}
