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
	string private _name = "BB";
	string private _symbol = "BB";
	uint256 public MAX_TOKEN = 10000;
	uint256 public PRICE_1 = 10 ether;
	uint256 public PRICE_2 = 5 ether;
	uint256 public PRICE_3 = 1 ether;
	uint256 public PRICE_4 = 0.5 ether;
	uint256 public saleTimestamp = 1642410000; // 
	uint256 public totalSupply = 0;
	bool public hasSaleStarted = true; //
	bool public whitelistSwitch = true;
	address public treasury = 0xd56e7bcF62a417b821e6cf7ee16dF7715a3e82AB; //

	mapping (address => uint256) public hasMint;
	mapping (uint256 => uint256) public idQuantity;
	mapping (uint256 => address[]) public idHolder;

	// Constructor
	// ------------------------------------------------------------------------
	constructor()ERC1155("https://blockbanana.com/metadata/{id}")
	EIP712("Block Banana", "1.0.0"){} 
	
	function name() public view virtual returns (string memory) {
		return _name;
	}

	function symbol() public view virtual returns (string memory) {
		return _symbol;
	}

	// Events
	// ------------------------------------------------------------------------
	event mintEvent(address owner, uint256 id, uint256 quantity, uint256 totalSupply);

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
	function mintNFT(uint256 id, uint256 quantity, uint256 maxQuantity, bytes memory SIGNATURE) external payable onlySale{
		if (whitelistSwitch == true){
			require(verify(maxQuantity, SIGNATURE), "Not eligible for whitelist.");
		}
		require(totalSupply.add(quantity) <= MAX_TOKEN, "Exceeds MAX_TOKEN.");
		require(quantity > 0 && hasMint[msg.sender].add(quantity) <= 2, "Exceeds max quantity.");
		require(id > 0 && id <= 4, "None token id.");
		
		if (id == 1){
			require(msg.value == PRICE_1.mul(quantity), "Ether value sent is not equal the price.");
			idHolder[1].push(msg.sender);
			idQuantity[1] = idQuantity[1].add(quantity);

		} else if (id == 2){
			require(msg.value == PRICE_2.mul(quantity), "Ether value sent is not equal the price.");
			idHolder[2].push(msg.sender);
			idQuantity[2] = idQuantity[2].add(quantity);

		} else if (id == 3){
			require(msg.value == PRICE_3.mul(quantity), "Ether value sent is not equal the price.");
			idHolder[3].push(msg.sender);
			idQuantity[3] = idQuantity[3].add(quantity);

		} else if (id == 4){
			require(msg.value == PRICE_4.mul(quantity), "Ether value sent is not equal the price.");
			idHolder[4].push(msg.sender);
			idQuantity[4] = idQuantity[4].add(quantity);

		}
		
		_mint(msg.sender, id, quantity, "");
		
		hasMint[msg.sender] = hasMint[msg.sender].add(quantity);
		totalSupply = totalSupply.add(quantity);

		emit mintEvent(msg.sender, id, quantity, totalSupply);
	}

	// Giveaway functions
	// ------------------------------------------------------------------------
	function giveaway(address to, uint256 token_id, uint256 quantity) external onlyOwner{
		require(totalSupply.add(quantity) <= MAX_TOKEN, "Exceeds MAX_TOKEN.");

		_mint(to, token_id, quantity, "");

		hasMint[to] = hasMint[to].add(quantity);
		totalSupply = totalSupply.add(quantity);
		idHolder[token_id].push(to);
		idQuantity[token_id] = idQuantity[token_id].add(quantity);

		emit mintEvent(to, token_id, quantity, totalSupply);
	}

	// Burn functions
	// ------------------------------------------------------------------------
	function burn(address to, uint256 burn_id, uint256 quantity) external onlyOwner {
		_burn(to, burn_id, quantity);
	}

    // Query address list of token id.
    function ownerOfToken(uint256 id) external view returns(address[] memory ) {
        uint256 addressCount = idHolder[id].length;
        
        if (addressCount == 0) {
            // Return an empty array
            return new address[](0);
        } else {
            address[] memory result = new address[](addressCount);
            uint256 index;
            for (index = 0; index < addressCount; index++) {
                result[index] = idHolder[id][index];
            }
            return result;
        }
    }

	// setting functions
	// ------------------------------------------------------------------------
	function setMAX_TOKEN(uint _MAX_TOKEN) external onlyOwner {
		MAX_TOKEN = _MAX_TOKEN;
	}

	function set_PRICE(uint256 token_id, uint256 _price) external onlyOwner {
		if (token_id == 1){
			PRICE_1 = _price;
		} else if (token_id == 2){
			PRICE_2 = _price;
		} else if (token_id == 3){
			PRICE_3 = _price;
		} else if (token_id == 4){
			PRICE_4 = _price;
		}
	}

	function setBaseURI(string memory baseURI) public onlyOwner {
		_setURI(baseURI);
	}

    function setSaleTime(bool _hasSaleStarted,uint256 _saleTimestamp, bool _whitelistSwitch) external onlyOwner {
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
