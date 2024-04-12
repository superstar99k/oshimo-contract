//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../Royalty/ERC2981Unique.sol";
import "../AccessControl/AccessControlRegistry.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "operator-filter-registry/src/OperatorFilterer.sol";

contract OshimoMarketplace is
	ERC2981Unique,
	AccessControlRegistry,
	ReentrancyGuard,
	OperatorFilterer
{
	using Counters for Counters.Counter;
	Counters.Counter private tokenUuids;
	Counters.Counter private tokensSold;

	uint256 oshimoFee = 0.0001 ether;
	bytes32 public constant NFT_ACCESS_ROLE = keccak256("NFT_ACCESS_ROLE");
	bytes32 public constant NFT_MINTER_ROLE = keccak256("NFT_MINTER_ROLE");

	bool isCanClientMint;

	struct OshimoNFTMeta {
		uint256 uuid;
		uint256 tokenId;
		address erc721;
		address payable seller;
		address payable owner;
		uint256 price;
		bool sold;
	}

	mapping(uint256 => OshimoNFTMeta) private oshimoNFTMeta;

	event List(
		uint256 indexed uuid,
		uint256 indexed tokenId,
		address indexed erc721,
		address seller,
		address owner,
		uint256 price,
		bool sold
	);

	event Buy(
		uint256 indexed uuid,
		uint256 indexed tokenId,
		address indexed erc721,
		address seller,
		address owner,
		uint256 price,
		bool sold
	);

	event SetFee(address indexed sender, uint256 oshimoFee, uint256 _fee);

	constructor(
		AccessControl _accessControler
	)
		AccessControlRegistry(_accessControler)
		OperatorFilterer(address(0), false)
	{
		isCanClientMint = false;
	}

	function setAccessControler(
		AccessControl newaccessControler
	) public onlyPermited(NFT_ACCESS_ROLE) {
		_setAccessControler(newaccessControler);
	}

	function setFee(uint256 _fee) external onlyPermited(NFT_MINTER_ROLE) {
		emit SetFee(msg.sender, oshimoFee, _fee);

		oshimoFee = _fee;
	}

	function getFee() public view returns (uint256) {
		return oshimoFee;
	}

	function getRoyaltyPermille(
		uint256 _uuid
	) public payable returns (uint256 permille) {
		return royalty[_uuid].permille;
	}

	function removeRoyaltyInfo(
		uint256 _uuid
	) external onlyPermited(NFT_MINTER_ROLE) {
		_removeRoyalty(_uuid);
	}

	function list(
		address _erc721,
		uint256 _tokenId,
		uint256 _price,
		address _receiver,
		uint256 _percentage
	) public payable returns (uint256) {
		require(_price > 0, "list: Price must be at least 1 wei");

		require(
			msg.value == oshimoFee,
			"list: Price must be equal to listing price"
		);

		uint256 newUuid = takeTokenID();

		oshimoNFTMeta[newUuid] = OshimoNFTMeta(
			newUuid,
			_tokenId,
			_erc721,
			payable(msg.sender),
			payable(address(this)),
			_price,
			false
		);

		IERC721(_erc721).transferFrom(msg.sender, address(this), _tokenId);

		_setRoyalty(newUuid, _receiver, _percentage);

		emit List(
			newUuid,
			_tokenId,
			_erc721,
			oshimoNFTMeta[_tokenId].seller,
			address(this),
			_price,
			false
		);

		return newUuid;
	}

	function getMyCreatedNftList()
		public
		view
		returns (OshimoNFTMeta[] memory)
	{
		uint256 ids = tokenUuids.current();
		uint256 nftCount = 0;
		uint256 index = 0;

		for (uint256 i = 0; i < ids; i++) {
			if (oshimoNFTMeta[i + 1].seller == msg.sender) {
				nftCount += 1;
			}
		}

		OshimoNFTMeta[] memory nfts = new OshimoNFTMeta[](nftCount);
		for (uint256 i = 0; i < ids; i++) {
			if (oshimoNFTMeta[i + 1].seller == msg.sender) {
				uint256 currentId = i + 1;

				OshimoNFTMeta storage currentItem = oshimoNFTMeta[currentId];
				nfts[index] = currentItem;
				index += 1;
			}
		}
		return nfts;
	}

	function buy(
		address _erc721,
		uint256 _uuid
	) public payable returns (uint256) {
		uint256 price = oshimoNFTMeta[_uuid].price;
		address seller = oshimoNFTMeta[_uuid].seller;
		uint256 tokenId = oshimoNFTMeta[_uuid].tokenId;

		require(
			msg.value == price,
			"buy: Please submit the asking price in order to complete the purchase"
		);

		oshimoNFTMeta[_uuid].owner = payable(msg.sender);
		oshimoNFTMeta[_uuid].sold = true;
		oshimoNFTMeta[_uuid].seller = payable(address(0));

		IERC721(_erc721).transferFrom(address(this), msg.sender, tokenId);

		oshimoNFTMeta[_uuid].owner = payable(msg.sender);
		tokensSold.increment();

		uint256 royaltyValue = (msg.value * royalty[_uuid].permille) / 1000;

		payable(royalty[_uuid].receiver).transfer(royaltyValue);

		payable(seller).transfer(msg.value - royaltyValue);

		emit Buy(
			_uuid,
			tokenId,
			_erc721,
			oshimoNFTMeta[tokenId].seller,
			msg.sender,
			price,
			true
		);

		return _uuid;
	}

	function getNftById(
		uint256 _uuid
	) public view returns (OshimoNFTMeta memory) {
		return oshimoNFTMeta[_uuid];
	}

	function getNftsBySender() public view returns (OshimoNFTMeta[] memory) {
		uint256 ids = tokenUuids.current();
		uint256 nftCount = 0;
		uint256 index = 0;

		for (uint256 i = 0; i < ids; i++) {
			if (oshimoNFTMeta[i + 1].owner == msg.sender) {
				nftCount += 1;
			}
		}

		OshimoNFTMeta[] memory nfts = new OshimoNFTMeta[](nftCount);

		for (uint256 i = 0; i < ids; i++) {
			if (oshimoNFTMeta[i + 1].owner == msg.sender) {
				uint256 currentId = oshimoNFTMeta[i + 1].tokenId;
				OshimoNFTMeta storage currentItem = oshimoNFTMeta[currentId];
				nfts[index] = currentItem;
				index += 1;
			}
		}
		return nfts;
	}

	function getListedNfts() public view returns (OshimoNFTMeta[] memory) {
		uint256 ids = tokenUuids.current();
		uint256 nftCount = 0;
		uint256 index = 0;

		for (uint256 i = 0; i < ids; i++) {
			if (oshimoNFTMeta[i + 1].owner == address(this)) {
				nftCount += 1;
			}
		}

		OshimoNFTMeta[] memory nfts = new OshimoNFTMeta[](nftCount);

		for (uint256 i = 0; i < ids; i++) {
			if (oshimoNFTMeta[i + 1].owner == msg.sender) {
				uint256 currentId = oshimoNFTMeta[i + 1].tokenId;

				OshimoNFTMeta storage currentNft = oshimoNFTMeta[currentId];
				nfts[index] = currentNft;
				index += 1;
			}
		}
		return nfts;
	}

	function getNftsByHolder(
		address _holder
	) public view returns (OshimoNFTMeta[] memory) {
		uint256 ids = tokenUuids.current();
		uint256 nftCount = 0;
		uint256 index = 0;

		for (uint256 i = 0; i < ids; i++) {
			if (oshimoNFTMeta[i + 1].owner == _holder) {
				nftCount += 1;
			}
		}

		OshimoNFTMeta[] memory nfts = new OshimoNFTMeta[](nftCount);

		for (uint256 i = 0; i < ids; i++) {
			if (oshimoNFTMeta[i + 1].owner == msg.sender) {
				uint256 currentId = oshimoNFTMeta[i + 1].tokenId;

				OshimoNFTMeta storage currentNft = oshimoNFTMeta[currentId];
				nfts[index] = currentNft;
				index += 1;
			}
		}
		return nfts;
	}

	function exists(uint256 _uuid) public view returns (bool) {
		return exists(_uuid);
	}

	function takeTokenID() internal returns (uint256) {
		tokenUuids.increment();
		return tokenUuids.current();
	}

	function nextTokenID() public view returns (uint256) {
		return tokenUuids.current() + 1;
	}

	function getTokenId(uint256 _uuid) public view returns (uint256) {
		return oshimoNFTMeta[_uuid].tokenId;
	}

	function getErc721(uint256 _uuid) public view returns (address) {
		return oshimoNFTMeta[_uuid].erc721;
	}

	function ownerOf(uint256 _uuid) public view returns (address) {
		uint256 tokenId = oshimoNFTMeta[_uuid].tokenId;
		address erc721 = oshimoNFTMeta[_uuid].erc721;
		return IERC721(erc721).ownerOf(tokenId);
	}

	function balanceOf(
		address _erc721,
		address _sender
	) public view returns (uint256) {
		return IERC721(_erc721).balanceOf(_sender);
	}

	function supportsInterface(
		bytes4 interfaceId
	) external pure override returns (bool) {
		return
			interfaceId == type(IERC721).interfaceId ||
			interfaceId == type(IERC165).interfaceId;
	}
}
