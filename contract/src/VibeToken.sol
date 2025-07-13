// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "./ERC20.sol";
import {Ownable} from "./Ownable.sol";

contract VibeToken is ERC20, Ownable {
    mapping(address => bool) public hasClaimed;
    mapping(bytes32 => bool) public usedProofs;
    
    uint256 public constant CLAIM_AMOUNT = 100 * 10**18; // 100 tokens
    address public verifier;
    
    event TokensClaimed(address indexed user, uint256 amount, bytes32 proofHash);
    event VerifierUpdated(address indexed newVerifier);
    
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(address(this), 1000000 * 10**18); // 1M tokens
    }
    
    function setVerifier(address _verifier) external onlyOwner {
        verifier = _verifier;
        emit VerifierUpdated(_verifier);
    }
    
    function claimTokens(
        bytes32 proofHash,
        bytes calldata signature
    ) external {
        require(!hasClaimed[msg.sender], "Already claimed");
        require(!usedProofs[proofHash], "Proof already used");
        require(verifier != address(0), "Verifier not set");
        
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, proofHash));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        
        require(recover(ethSignedMessageHash, signature) == verifier, "Invalid signature");
        
        hasClaimed[msg.sender] = true;
        usedProofs[proofHash] = true;
        
        _transfer(address(this), msg.sender, CLAIM_AMOUNT);
        
        emit TokensClaimed(msg.sender, CLAIM_AMOUNT, proofHash);
    }
    
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        if (signature.length != 65) {
            return address(0);
        }
        
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        
        if (v < 27) {
            v += 27;
        }
        
        if (v != 27 && v != 28) {
            return address(0);
        }
        
        return ecrecover(hash, v, r, s);
    }
}