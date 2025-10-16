// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {GuardianManager} from "../src/GuardianManager.sol";

contract DeployGuardianManager is Script {
    function run() external returns (GuardianManager) {
        // Securely read the private key from the .env file.
        // This is the professional pattern.
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions using the loaded private key.
        vm.startBroadcast(deployerPrivateKey);
        
        GuardianManager guardianManager = new GuardianManager();
        
        vm.stopBroadcast();
        
        return guardianManager;
    }
}