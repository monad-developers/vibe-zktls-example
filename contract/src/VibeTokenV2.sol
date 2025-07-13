// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "./ERC20.sol";
import {Ownable} from "./Ownable.sol";
import {IPrimusZKTLS, Attestation} from "@primuslabs/zktls-contracts/src/IPrimusZKTLS.sol";
import {JsonParser} from "./JsonParser.sol";

contract VibeTokenV2 is ERC20, Ownable {
    using JsonParser for string;
    mapping(address => bool) public hasClaimed;
    mapping(string => bool) public usedScreenNames;
    
    uint256 public constant CLAIM_AMOUNT = 100 * 10**18; // 100 tokens
    address public primusAddress;
    
    event TokensClaimed(address indexed user, uint256 amount, string screenName);
    event PrimusAddressUpdated(address indexed newAddress);
    
    constructor(
        string memory name, 
        string memory symbol,
        address _primusAddress
    ) ERC20(name, symbol) {
        require(_primusAddress != address(0), "Invalid Primus address");
        primusAddress = _primusAddress;
        _mint(address(this), 1000000 * 10**18); // 1M tokens
    }
    
    function setPrimusAddress(address _primusAddress) external onlyOwner {
        require(_primusAddress != address(0), "Invalid Primus address");
        primusAddress = _primusAddress;
        emit PrimusAddressUpdated(_primusAddress);
    }
    
    function claimTokens(Attestation calldata attestation) external {
        require(!hasClaimed[msg.sender], "Already claimed");
        
        // Verify attestation with Primus contract
        IPrimusZKTLS(primusAddress).verifyAttestation(attestation);
        
        // Verify the attestation is for the caller
        require(attestation.recipient == msg.sender, "Invalid recipient");
        
        // Extract screen name from attestation data
        string memory screenName = attestation.data.extractValue("screen_name");
        require(bytes(screenName).length > 0, "Screen name not found");
        require(!usedScreenNames[screenName], "Screen name already used");
        
        // Mark as claimed
        hasClaimed[msg.sender] = true;
        usedScreenNames[screenName] = true;
        
        // Transfer tokens
        _transfer(address(this), msg.sender, CLAIM_AMOUNT);
        
        emit TokensClaimed(msg.sender, CLAIM_AMOUNT, screenName);
    }
}