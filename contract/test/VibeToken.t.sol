// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {VibeToken} from "../src/VibeToken.sol";

contract VibeTokenTest is Test {
    VibeToken public token;
    address public owner = address(1);
    address public verifier = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public user = address(3);
    
    function setUp() public {
        vm.prank(owner);
        token = new VibeToken("Vibe Token", "VIBE");
        
        vm.prank(owner);
        token.setVerifier(verifier);
    }
    
    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000000 * 10**18);
        assertEq(token.balanceOf(address(token)), 1000000 * 10**18);
    }
    
    function testClaimTokens() public {
        bytes32 proofHash = keccak256("proof");
        bytes32 messageHash = keccak256(abi.encodePacked(user, proofHash));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        
        // Use private key 2 which corresponds to verifier address
        // Private key 2 in Foundry = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
        // Address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.prank(user);
        token.claimTokens(proofHash, signature);
        
        assertEq(token.balanceOf(user), 100 * 10**18);
        assertTrue(token.hasClaimed(user));
        assertTrue(token.usedProofs(proofHash));
    }
    
    function testCannotClaimTwice() public {
        bytes32 proofHash = keccak256("proof");
        bytes32 messageHash = keccak256(abi.encodePacked(user, proofHash));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        
        // Use private key 2 which corresponds to verifier address
        // Private key 2 in Foundry = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
        // Address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.prank(user);
        token.claimTokens(proofHash, signature);
        
        vm.expectRevert("Already claimed");
        vm.prank(user);
        token.claimTokens(proofHash, signature);
    }
    
    function testInvalidSignature() public {
        bytes32 proofHash = keccak256("proof");
        bytes memory invalidSignature = hex"00";
        
        vm.expectRevert("Invalid signature");
        vm.prank(user);
        token.claimTokens(proofHash, invalidSignature);
    }
}