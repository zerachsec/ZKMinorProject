// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SimpleZKAuth.sol";

/**
 * @title Deploy SimpleZKAuth
 * @notice Simple deployment script for ZKAuth
 */
contract DeploySimpleZKAuth is Script {
    function run() external {
        // Get private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy SimpleZKAuth
        SimpleZKAuth zkAuth = new SimpleZKAuth();

        console.log("========================================");
        console.log("SimpleZKAuth Deployed Successfully!");
        console.log("========================================");
        console.log("Contract Address:", address(zkAuth));
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("Network Chain ID:", block.chainid);
        console.log("Auth Duration:", zkAuth.AUTH_DURATION(), "seconds (24 hours)");
        console.log("========================================");

        console.log("\nNEXT STEPS:");
        console.log(
            "1. Register a commitment: cast send", address(zkAuth), '"registerCommitment(bytes32)" <YOUR_COMMITMENT>'
        );
        console.log(
            "2. Authenticate: cast send", address(zkAuth), '"authenticate(uint256,bytes32)" <SECRET> <COMMITMENT>'
        );
        console.log("3. Check auth: cast call", address(zkAuth), '"checkAuth(address)" <YOUR_ADDRESS>');

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
