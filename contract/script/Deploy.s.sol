// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {VibeToken} from "../src/VibeToken.sol";

contract DeployScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address verifier = vm.envAddress("VERIFIER_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        VibeToken token = new VibeToken("Vibe Token", "VIBE");
        console.log("VibeToken deployed at:", address(token));
        
        token.setVerifier(verifier);
        console.log("Verifier set to:", verifier);
        
        vm.stopBroadcast();
    }
}