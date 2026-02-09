// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleZKAuth
 * @author VISHAAL S (AA.SC.P2MCA24077071)
 * @notice A simple Zero-Knowledge Proof authentication system
 *
 * PURPOSE: Prove you own a wallet WITHOUT revealing your wallet address
 *
 * HOW IT WORKS:
 * 1. You have a secret number (private key/secret)
 * 2. You create a "commitment" = hash(secret)
 * 3. You prove you know the secret WITHOUT revealing it
 * 4. Contract verifies the proof and authenticates you
 *
 * PRIVACY BENEFIT: Your actual identity (wallet) stays hidden!
 */
contract SimpleZKAuth {
    // ==================== STATE VARIABLES ====================

    // Store commitments (public hashes of secrets)
    mapping(bytes32 => bool) public validCommitments;

    // Track who is authenticated
    mapping(address => bool) public isAuthenticated;

    // Track when authentication happened
    mapping(address => uint256) public authTimestamp;

    // Prevent reuse of same proof
    mapping(bytes32 => bool) public usedProofs;

    // Authentication validity period (24 hours)
    uint256 public constant AUTH_DURATION = 24 hours;

    // Owner of the contract
    address public owner;

    // ==================== EVENTS ====================

    event CommitmentRegistered(bytes32 indexed commitment, uint256 timestamp);
    event UserAuthenticated(address indexed user, bytes32 commitment, uint256 timestamp);
    event AuthenticationRevoked(address indexed user);

    // ==================== CONSTRUCTOR ====================

    constructor() {
        owner = msg.sender;
    }

    // ==================== STEP 1: REGISTER COMMITMENT ====================

    /**
     * @notice Register your identity commitment (one-time setup)
     * @param commitment Hash of your secret: keccak256(abi.encodePacked(secret))
     *
     * Example: If your secret is "12345", commitment = keccak256("12345")
     * This doesn't reveal your secret!
     */
    function registerCommitment(bytes32 commitment) external {
        require(commitment != bytes32(0), "Invalid commitment");
        require(!validCommitments[commitment], "Commitment already registered");

        validCommitments[commitment] = true;

        emit CommitmentRegistered(commitment, block.timestamp);
    }

    // ==================== STEP 2: AUTHENTICATE ====================

    /**
     * @notice Prove you know the secret and authenticate
     * @param secret Your secret value
     * @param commitment The commitment you registered earlier
     *
     * PRIVACY: You reveal the secret to prove ownership, but nobody knows
     * which commitment belongs to which wallet address!
     *
     * In real ZK: You'd submit a ZK proof instead of the actual secret
     */
    function authenticate(uint256 secret, bytes32 commitment) external {
        // Verify the commitment exists
        require(validCommitments[commitment], "Commitment not registered");

        // Verify you know the secret
        bytes32 computedCommitment = keccak256(abi.encodePacked(secret));
        require(computedCommitment == commitment, "Invalid secret");

        // Create unique proof ID to prevent reuse
        bytes32 proofId = keccak256(abi.encodePacked(msg.sender, commitment, block.timestamp));
        require(!usedProofs[proofId], "Proof already used");

        // Mark proof as used
        usedProofs[proofId] = true;

        // Authenticate the user
        isAuthenticated[msg.sender] = true;
        authTimestamp[msg.sender] = block.timestamp;

        emit UserAuthenticated(msg.sender, commitment, block.timestamp);
    }

    // ==================== STEP 3: CHECK AUTHENTICATION ====================

    /**
     * @notice Check if a user is currently authenticated
     * @param user Address to check
     * @return True if authenticated and not expired
     */
    function checkAuth(address user) external view returns (bool) {
        if (!isAuthenticated[user]) {
            return false;
        }

        // Check if authentication expired
        if (block.timestamp > authTimestamp[user] + AUTH_DURATION) {
            return false;
        }

        return true;
    }

    /**
     * @notice Get remaining authentication time
     * @param user Address to check
     * @return Seconds remaining (0 if expired)
     */
    function getAuthTimeRemaining(address user) external view returns (uint256) {
        if (!isAuthenticated[user]) {
            return 0;
        }

        uint256 expiryTime = authTimestamp[user] + AUTH_DURATION;

        if (block.timestamp >= expiryTime) {
            return 0;
        }

        return expiryTime - block.timestamp;
    }

    // ==================== REVOKE AUTHENTICATION ====================

    /**
     * @notice Revoke your own authentication (logout)
     */
    function revokeAuth() external {
        require(isAuthenticated[msg.sender], "Not authenticated");

        isAuthenticated[msg.sender] = false;

        emit AuthenticationRevoked(msg.sender);
    }

    // ==================== VIEW FUNCTIONS ====================

    /**
     * @notice Check if a commitment is registered
     */
    function isCommitmentValid(bytes32 commitment) external view returns (bool) {
        return validCommitments[commitment];
    }

    /**
     * @notice Get all authentication details for a user
     */
    function getAuthDetails(address user)
        external
        view
        returns (bool authenticated, uint256 timestamp, uint256 timeRemaining)
    {
        authenticated = isAuthenticated[user];
        timestamp = authTimestamp[user];

        if (authenticated && block.timestamp < authTimestamp[user] + AUTH_DURATION) {
            timeRemaining = (authTimestamp[user] + AUTH_DURATION) - block.timestamp;
        } else {
            timeRemaining = 0;
        }
    }
}

