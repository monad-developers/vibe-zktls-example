// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {VibeTokenV2} from "../src/VibeTokenV2.sol";

contract DeployV2Script is Script {
    function run() public {
        // Default to Monad Testnet Primus address
        address primusAddress = 0x1Ad7fD53206fDc3979C672C0466A1c48AF47B431;
        
        // Use external account (passed via --account parameter)
        vm.startBroadcast();
        
        VibeTokenV2 token = new VibeTokenV2("Vibe Token", "VIBE", primusAddress);
        console.log("VibeTokenV2 deployed at:", address(token));
        console.log("Primus address set to:", primusAddress);
        console.log("Deployed by:", msg.sender);
        
        vm.stopBroadcast();
    }
    
    function run(address primusAddress) public {
        // Use custom Primus address
        vm.startBroadcast();
        
        VibeTokenV2 token = new VibeTokenV2("Vibe Token", "VIBE", primusAddress);
        console.log("VibeTokenV2 deployed at:", address(token));
        console.log("Primus address set to:", primusAddress);
        console.log("Deployed by:", msg.sender);
        
        vm.stopBroadcast();
    }
}