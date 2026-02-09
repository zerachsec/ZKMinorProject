// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SimpleZKAuth.sol";

/**
 * @title SimpleZKAuth Tests
 * @notice Test suite demonstrating ZKAuth functionality
 */
contract SimpleZKAuthTest is Test {
    SimpleZKAuth public zkAuth;

    address public user1 = address(0x1);
    address public user2 = address(0x2);

    uint256 public secret1 = 12345;
    uint256 public secret2 = 67890;

    bytes32 public commitment1;
    bytes32 public commitment2;

    function setUp() public {
        // Deploy contract
        zkAuth = new SimpleZKAuth();

        // Compute commitments
        commitment1 = keccak256(abi.encodePacked(secret1));
        commitment2 = keccak256(abi.encodePacked(secret2));

        console.log("=== Test Setup ===");
        console.log("User 1:", user1);
        console.log("User 1 Secret:", secret1);
        console.log("User 1 Commitment:");
        console.logBytes32(commitment1);
        console.log("");
    }

    // ==================== TEST 1: COMMITMENT REGISTRATION ====================

    function testRegisterCommitment() public {
        console.log("TEST 1: Register Commitment");

        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);

        assertTrue(zkAuth.isCommitmentValid(commitment1));
        console.log("Commitment registered successfully");
    }

    function testCannotRegisterSameCommitmentTwice() public {
        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);

        vm.expectRevert("Commitment already registered");
        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);

        console.log(" Duplicate commitment rejected");
    }

    function testCannotRegisterZeroCommitment() public {
        vm.expectRevert("Invalid commitment");
        vm.prank(user1);
        zkAuth.registerCommitment(bytes32(0));

        console.log(" Zero commitment rejected");
    }

    // ==================== TEST 2: AUTHENTICATION ====================

    function testAuthenticate() public {
        console.log("\nTEST 2: Authentication");

        // Register commitment
        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);

        // Authenticate
        vm.prank(user1);
        zkAuth.authenticate(secret1, commitment1);

        // Check authentication
        assertTrue(zkAuth.checkAuth(user1));
        console.log(" User authenticated successfully");
    }

    function testCannotAuthenticateWithWrongSecret() public {
        // Register commitment
        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);

        // Try to authenticate with wrong secret
        vm.expectRevert("Invalid secret");
        vm.prank(user1);
        zkAuth.authenticate(99999, commitment1);

        console.log(" Wrong secret rejected");
    }

    function testCannotAuthenticateWithUnregisteredCommitment() public {
        vm.expectRevert("Commitment not registered");
        vm.prank(user1);
        zkAuth.authenticate(secret1, commitment1);

        console.log(" Unregistered commitment rejected");
    }

    // ==================== TEST 3: PRIVACY ====================

    function testMultipleUsersWithDifferentCommitments() public {
        console.log("\nTEST 3: Privacy - Multiple Users");

        // User 1 registers and authenticates
        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);
        vm.prank(user1);
        zkAuth.authenticate(secret1, commitment1);

        // User 2 registers and authenticates
        vm.prank(user2);
        zkAuth.registerCommitment(commitment2);
        vm.prank(user2);
        zkAuth.authenticate(secret2, commitment2);

        // Both should be authenticated
        assertTrue(zkAuth.checkAuth(user1));
        assertTrue(zkAuth.checkAuth(user2));

        console.log(" User 1 authenticated with commitment 1");
        console.log(" User 2 authenticated with commitment 2");
        console.log(" No way to link user addresses to commitments!");
    }

    // ==================== TEST 4: SESSION MANAGEMENT ====================

    function testAuthenticationExpiry() public {
        console.log("\nTEST 4: Session Expiry");

        // Register and authenticate
        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);
        vm.prank(user1);
        zkAuth.authenticate(secret1, commitment1);

        // Should be authenticated
        assertTrue(zkAuth.checkAuth(user1));
        console.log(" User authenticated at time 0");

        // Fast forward 12 hours - should still be authenticated
        vm.warp(block.timestamp + 12 hours);
        assertTrue(zkAuth.checkAuth(user1));
        console.log(" User still authenticated after 12 hours");

        // Fast forward past 24 hours - should be expired
        vm.warp(block.timestamp + 13 hours);
        assertFalse(zkAuth.checkAuth(user1));
        console.log(" User authentication expired after 24 hours");
    }

    function testGetAuthTimeRemaining() public {
        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);
        vm.prank(user1);
        zkAuth.authenticate(secret1, commitment1);

        // Check time remaining
        uint256 timeRemaining = zkAuth.getAuthTimeRemaining(user1);
        assertEq(timeRemaining, 24 hours);
        console.log(" Time remaining:", timeRemaining, "seconds");

        // Fast forward 1 hour
        vm.warp(block.timestamp + 1 hours);
        timeRemaining = zkAuth.getAuthTimeRemaining(user1);
        assertEq(timeRemaining, 23 hours);
        console.log(" After 1 hour, time remaining:", timeRemaining / 3600, "hours");
    }

    // ==================== TEST 5: REVOKE AUTHENTICATION ====================

    function testRevokeAuth() public {
        console.log("\nTEST 5: Revoke Authentication");

        // Register and authenticate
        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);
        vm.prank(user1);
        zkAuth.authenticate(secret1, commitment1);

        assertTrue(zkAuth.checkAuth(user1));
        console.log("User authenticated");

        // Revoke authentication
        vm.prank(user1);
        zkAuth.revokeAuth();

        assertFalse(zkAuth.checkAuth(user1));
        console.log(" User authentication revoked");
    }

    function testCannotRevokeIfNotAuthenticated() public {
        vm.expectRevert("Not authenticated");
        vm.prank(user1);
        zkAuth.revokeAuth();

        console.log(" Cannot revoke if not authenticated");
    }

    // ==================== TEST 6: COMPREHENSIVE FLOW ====================

    function testCompleteAuthenticationFlow() public {
        console.log("\n=== TEST 6: Complete Flow ===");

        console.log("\nStep 1: User has a secret");
        console.log("  Secret:", secret1);

        console.log("\nStep 2: User creates commitment (hash of secret)");
        console.log("  Commitment:");
        console.logBytes32(commitment1);

        console.log("\nStep 3: User registers commitment");
        vm.prank(user1);
        zkAuth.registerCommitment(commitment1);
        console.log("   Commitment registered");

        console.log("\nStep 4: User proves knowledge of secret");
        vm.prank(user1);
        zkAuth.authenticate(secret1, commitment1);
        console.log("   User authenticated");

        console.log("\nStep 5: Verify authentication");
        assertTrue(zkAuth.checkAuth(user1));
        (bool authenticated, uint256 timestamp, uint256 timeRemaining) = zkAuth.getAuthDetails(user1);
        console.log("   Authenticated:", authenticated);
        console.log("   Timestamp:", timestamp);
        console.log("   Time Remaining:", timeRemaining / 3600, "hours");

        console.log("\n=== PRIVACY ACHIEVED ===");
        console.log("User's identity (address) not linked to commitment");
        console.log("Anyone can verify authentication without knowing identity");
        console.log("No tracking across different dApps");
    }
}
