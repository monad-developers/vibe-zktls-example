// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {VibeTokenV2} from "../src/VibeTokenV2.sol";
import {IPrimusZKTLS, Attestation, AttNetworkRequest, AttNetworkResponseResolve, Attestor} from "@primuslabs/zktls-contracts/src/IPrimusZKTLS.sol";

contract AttestationTest is Test {
    VibeTokenV2 public token;
    address public constant PRIMUS_ADDRESS = 0x1Ad7fD53206fDc3979C672C0466A1c48AF47B431;
    address public user = 0x5A421D1280C31ac17B9b25275cFA1c6c30dF9aab;
    
    function setUp() public {
        // Deploy the token contract
        token = new VibeTokenV2("Vibe Token", "VIBE", PRIMUS_ADDRESS);
    }
    
    function testPrimusContractExists() public {
        // Test if the Primus contract exists on the forked network
        bytes memory code = PRIMUS_ADDRESS.code;
        console.log("Primus contract code length:", code.length);
        
        if (code.length == 0) {
            console.log("ERROR: Primus contract not found on forked network");
        } else {
            console.log("SUCCESS: Primus contract found");
        }
    }
    
    function testAttestorStatus() public {
        // Check if the attestor is registered in the Primus contract
        address attestorAddr = 0xDB736B13E2f522dBE18B2015d0291E4b193D8eF6;
        
        console.log("Checking attestor status...");
        console.log("Attestor address:", attestorAddr);
        
        // Try to call some functions on the Primus contract to understand its state
        IPrimusZKTLS primus = IPrimusZKTLS(PRIMUS_ADDRESS);
        
        // The Primus contract might have functions to check attestor status
        // Let's try to call some basic functions
        console.log("Primus contract address:", PRIMUS_ADDRESS);
        
        // Check if we can call any view functions
        bytes memory callData = abi.encodeWithSignature("owner()");
        (bool success, bytes memory result) = PRIMUS_ADDRESS.staticcall(callData);
        
        if (success) {
            console.log("SUCCESS: owner() call succeeded");
            if (result.length >= 32) {
                address owner = abi.decode(result, (address));
                console.log("Contract owner:", owner);
            }
        } else {
            console.log("ERROR: owner() call failed");
        }
        
        // Try to check attestor registration
        callData = abi.encodeWithSignature("attestors(address)", attestorAddr);
        (success, result) = PRIMUS_ADDRESS.staticcall(callData);
        
        if (success) {
            console.log("SUCCESS: attestors() call succeeded");
            console.logBytes(result);
        } else {
            console.log("ERROR: attestors() call failed");
        }
    }
    
    function testNetworkState() public {
        console.log("Checking network state...");
        console.log("Block number:", block.number);
        console.log("Block timestamp:", block.timestamp);
        console.log("Chain ID:", block.chainid);
        
        // Check if this matches the attestation timestamp
        uint64 attestationTimestamp = 0x197ee0acc48;
        console.log("Attestation timestamp:", attestationTimestamp);
        
        if (block.timestamp > attestationTimestamp) {
            console.log("Current block is AFTER attestation timestamp");
            console.log("Time difference:", block.timestamp - attestationTimestamp);
        } else {
            console.log("Current block is BEFORE attestation timestamp");
            console.log("Time difference:", attestationTimestamp - block.timestamp);
        }
        
        // The problem might be that we forked at the wrong block height
        // The attestation was created at a specific time/block, but our fork might be at a different state
    }
    
    function testReconstructSignedMessage() public {
        // Let's try to understand what message was actually signed
        // This might help us understand why the signature verification fails
        
        AttNetworkRequest memory request = AttNetworkRequest({
            url: "https://api.x.com/1.1/account/settings.json?include_ext_sharing_audiospaces_listening_data_with_followers=true&include_mention_filter=true&include_nsfw_user_flag=true&include_nsfw_admin_flag=true&include_ranked_timeline=true&include_alt_text_compose=true&ext=ssoConnections&include_country_code=true&include_ext_dm_nsfw_media_filter=true",
            header: "{}",
            method: "GET",
            body: ""
        });
        
        AttNetworkResponseResolve[] memory responseResolve = new AttNetworkResponseResolve[](1);
        responseResolve[0] = AttNetworkResponseResolve({
            keyName: "screen_name",
            parseType: "",
            parsePath: "$.screen_name"
        });
        
        Attestor[] memory attestors = new Attestor[](1);
        attestors[0] = Attestor({
            attestorAddr: 0xDB736B13E2f522dBE18B2015d0291E4b193D8eF6,
            url: "https://primuslabs.xyz"
        });
        
        bytes[] memory signatures = new bytes[](1);
        signatures[0] = hex"f632838540ec6a372a848d2f9554aa72803112a7098e506c35b550635a2f39f57c83f68c00a02b6ce2c9f4df15f0b7c4dc4c4c0efda1acdc01dc56acda685e2b1b";
        
        Attestation memory attestation = Attestation({
            recipient: user,
            request: request,
            reponseResolve: responseResolve,
            data: '{"screen_name":"BoxMrChen"}',
            attConditions: '[{"op":"REVEAL_STRING","field":"$.screen_name"}]',
            timestamp: 0x197ee0acc48,
            additionParams: '{"algorithmType":"proxytls"}',
            attestors: attestors,
            signatures: signatures
        });
        
        console.log("Reconstructing signed message...");
        
        // The signed message is likely a hash of the attestation data
        // Let's try different hashing approaches that Primus might use
        
        bytes32 messageHash1 = keccak256(abi.encode(attestation));
        console.log("Message hash (full encode):");
        console.logBytes32(messageHash1);
        
        bytes32 messageHash2 = keccak256(abi.encodePacked(
            attestation.recipient,
            attestation.request.url,
            attestation.data,
            attestation.timestamp
        ));
        console.log("Message hash (packed basic):");
        console.logBytes32(messageHash2);
        
        bytes32 messageHash3 = keccak256(abi.encodePacked(
            attestation.recipient,
            keccak256(bytes(attestation.request.url)),
            keccak256(bytes(attestation.data)),
            attestation.timestamp
        ));
        console.log("Message hash (packed with sub-hashes):");
        console.logBytes32(messageHash3);
    }
}