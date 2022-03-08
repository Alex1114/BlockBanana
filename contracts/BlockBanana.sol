//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//  ___  _           _       ___
// | _ )| | ___  __ | |__   | _ ) __ _  _ _   __ _  _ _   __ _
// | _ \| |/ _ \/ _|| / /   | _ \/ _` || ' \ / _` || ' \ / _` |
// |___/|_|\___/\__||_\_\   |___/\__,_||_||_|\__,_||_||_|\__,_|

contract BlockBanana is Ownable, EIP712, ERC1155{

	using SafeMath for uint256;
	using Strings for uint256;

	// Variables
	// ------------------------------------------------------------------------
	// string private _name = "Block Banana";
	string private _name = "BB"; //
	string private _symbol = "BB"; //
	uint256 public MAX_TOKEN = 10000;
	uint256 public HOLDER_MAX = 2;
	uint256 public PRICE = 0.2 ether;
	uint256 public saleTimestamp = 1642410000; // 
	uint256 public totalSupply = 0;
	bool public hasSaleStarted = true; //
	bool public whitelistSwitch = true;
	address public treasury = 0x5279246E3626Cebe71a4c181382A50a71d2A4156; //

	mapping (address => uint256) public hasMint;

	// Constructor
	// ------------------------------------------------------------------------
	constructor()ERC1155("https://gateway.pinata.cloud/ipfs/Qmak7SQmUrh9ujcBLu6DdJwYU7Wtyp1gx67iuHFR4woJ7o")
	EIP712("Block Banana", "1.0.0"){} 
	
	function name() public view virtual returns (string memory) {
		return _name;
	}

	function symbol() public view virtual returns (string memory) {
		return _symbol;
	}

	// Events
	// ------------------------------------------------------------------------
	event mintEvent(address owner, uint256 quantity, uint256 totalSupply);

	// Modifiers
	// ------------------------------------------------------------------------
    modifier onlySale() {
		require(hasSaleStarted == true, "SALE_NOT_ACTIVE");
        require(block.timestamp >= saleTimestamp, "NOT_IN_SALE_TIME");
        _;
    }

	// Verify functions
	// ------------------------------------------------------------------------
	function verify(uint256 maxQuantity, bytes memory SIGNATURE) public view returns (bool){
		address recoveredAddr = ECDSA.recover(_hashTypedDataV4(keccak256(abi.encode(keccak256("NFT(address addressForClaim,uint256 maxQuantity)"), _msgSender(), maxQuantity))), SIGNATURE);

		return owner() == recoveredAddr;
	}

	// Mint functions
	// ------------------------------------------------------------------------
	function mintNFT(uint256 quantity, uint256 maxQuantity, bytes memory SIGNATURE) external payable onlySale{
		if (whitelistSwitch == true){
			require(verify(maxQuantity, SIGNATURE), "Not eligible for whitelist.");
		}
		require(totalSupply.add(quantity) <= MAX_TOKEN, "Exceeds MAX_TOKEN.");
		require(quantity > 0 && hasMint[msg.sender].add(quantity) <= HOLDER_MAX, "Exceeds max quantity.");
		require(msg.value == PRICE.mul(quantity), "Ether value sent is not equal the price.");

		_mint(msg.sender, 1, quantity, "");
		
		hasMint[msg.sender] = hasMint[msg.sender].add(quantity);
		totalSupply = totalSupply.add(quantity);

		emit mintEvent(msg.sender, quantity, totalSupply);
	}

	// Giveaway functions
	// ------------------------------------------------------------------------
	function giveaway(address to, uint256 quantity) external onlyOwner{
		require(totalSupply.add(quantity) <= MAX_TOKEN, "Exceeds MAX_TOKEN.");
		require(quantity > 0 && hasMint[to].add(quantity) <= HOLDER_MAX, "Exceeds max quantity.");

		_mint(to, 1, quantity, "");

		hasMint[to] = hasMint[to].add(quantity);
		totalSupply = totalSupply.add(quantity);

		emit mintEvent(to, quantity, totalSupply);
	}

	// Burn functions
	// ------------------------------------------------------------------------
	function burn(address to, uint256 quantity) external onlyOwner {
		_burn(to, 1, quantity);
		hasMint[to] = hasMint[to].sub(quantity);
	}

	// setting functions
	// ------------------------------------------------------------------------
	function setMAX_TOKEN(uint256 _MAX_TOKEN, uint256 _HOLDER_MAX) external onlyOwner {
		MAX_TOKEN = _MAX_TOKEN;
		HOLDER_MAX = _HOLDER_MAX;
	}

	function set_PRICE(uint256 _price) external onlyOwner {
		PRICE = _price;
	}

	function setBaseURI(string memory baseURI) public onlyOwner {
		_setURI(baseURI);
	}

    function setSaleTime(bool _hasSaleStarted, uint256 _saleTimestamp, bool _whitelistSwitch) external onlyOwner {
        hasSaleStarted = _hasSaleStarted;
        saleTimestamp = _saleTimestamp;
		whitelistSwitch = _whitelistSwitch;
    }

	// Withdrawal functions
	// ------------------------------------------------------------------------
    function setTreasury(address _treasury) external onlyOwner {
        require(treasury != address(0), "SETTING_ZERO_ADDRESS");
        treasury = _treasury;
    }

	function withdrawAll() public payable onlyOwner {
		require(payable(treasury).send(address(this).balance));
	}

}
