// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {VibeTokenV2} from "../src/VibeTokenV2.sol";
import {Attestation, AttNetworkRequest, AttNetworkResponseResolve, Attestor} from "@primuslabs/zktls-contracts/src/IPrimusZKTLS.sol";

contract VibeTokenV2Test is Test {
    VibeTokenV2 public token;
    address public owner = address(1);
    address public user = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    
    // Monad testnet Primus contract address (you'll need to get the actual address)
    address public primusAddress = address(0x1234); // Replace with actual Primus address on Monad
    
    string constant FORK_URL = "https://testnet-rpc.monad.xyz";
    uint256 forkId;
    
    function setUp() public {
        // Fork Monad testnet
        forkId = vm.createFork(FORK_URL);
        vm.selectFork(forkId);
        
        // Deploy token contract
        vm.prank(owner);
        token = new VibeTokenV2("Vibe Token", "VIBE", primusAddress);
    }
    
    function testInitialSetup() public view {
        assertEq(token.totalSupply(), 1000000 * 10**18);
        assertEq(token.balanceOf(address(token)), 1000000 * 10**18);
        assertEq(token.primusAddress(), primusAddress);
    }
    
    function testClaimTokensWithMockAttestation() public {
        // Create mock network request
        AttNetworkRequest memory request = AttNetworkRequest({
            url: "https://api.twitter.com/2/users/me",
            header: "{}",
            method: "GET",
            body: ""
        });
        
        // Create empty arrays for the attestation
        AttNetworkResponseResolve[] memory responseResolve = new AttNetworkResponseResolve[](0);
        Attestor[] memory attestors = new Attestor[](0);
        bytes[] memory signatures = new bytes[](0);
        
        // Create mock attestation
        Attestation memory attestation = Attestation({
            recipient: user,
            request: request,
            reponseResolve: responseResolve,
            data: "{\"username\":\"testuser\"}",
            attConditions: "",
            timestamp: uint64(block.timestamp),
            additionParams: "",
            attestors: attestors,
            signatures: signatures
        });
        
        // Mock the Primus contract verification
        vm.mockCall(
            primusAddress,
            abi.encodeWithSelector(0x0ef3e680), // verifyAttestation selector
            abi.encode(true)
        );
        
        // Claim tokens
        vm.prank(user);
        token.claimTokens(attestation);
        
        // Verify claim
        assertEq(token.balanceOf(user), 100 * 10**18);
        assertTrue(token.hasClaimed(user));
    }
    
    function testCannotClaimTwice() public {
        // Create attestation using helper
        Attestation memory attestation = _createMockAttestation(user);
        
        vm.mockCall(
            primusAddress,
            abi.encodeWithSelector(0x0ef3e680),
            abi.encode(true)
        );
        
        vm.prank(user);
        token.claimTokens(attestation);
        
        vm.expectRevert("Already claimed");
        vm.prank(user);
        token.claimTokens(attestation);
    }
    
    function testInvalidTwitterURL() public {
        AttNetworkRequest memory request = AttNetworkRequest({
            url: "https://api.facebook.com/me", // Wrong URL
            header: "{}",
            method: "GET",
            body: ""
        });
        
        Attestation memory attestation = _createMockAttestationWithRequest(user, request);
        
        vm.mockCall(
            primusAddress,
            abi.encodeWithSelector(0x0ef3e680),
            abi.encode(true)
        );
        
        vm.expectRevert("Invalid Twitter attestation");
        vm.prank(user);
        token.claimTokens(attestation);
    }
    
    function testInvalidRecipient() public {
        address wrongUser = address(0x123);
        Attestation memory attestation = _createMockAttestation(wrongUser);
        
        vm.mockCall(
            primusAddress,
            abi.encodeWithSelector(0x0ef3e680),
            abi.encode(true)
        );
        
        vm.expectRevert("Invalid recipient");
        vm.prank(user);
        token.claimTokens(attestation);
    }
    
    // Helper functions
    function _createMockAttestation(address recipient) internal view returns (Attestation memory) {
        AttNetworkRequest memory request = AttNetworkRequest({
            url: "https://api.twitter.com/2/users/me",
            header: "{}",
            method: "GET",
            body: ""
        });
        
        return _createMockAttestationWithRequest(recipient, request);
    }
    
    function _createMockAttestationWithRequest(
        address recipient, 
        AttNetworkRequest memory request
    ) internal view returns (Attestation memory) {
        AttNetworkResponseResolve[] memory responseResolve = new AttNetworkResponseResolve[](0);
        Attestor[] memory attestors = new Attestor[](0);
        bytes[] memory signatures = new bytes[](0);
        
        return Attestation({
            recipient: recipient,
            request: request,
            reponseResolve: responseResolve,
            data: "{\"username\":\"testuser\"}",
            attConditions: "",
            timestamp: uint64(block.timestamp),
            additionParams: "",
            attestors: attestors,
            signatures: signatures
        });
    }
}