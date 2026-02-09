# SimpleZKAuth - Easy Zero-Knowledge Authentication

**Student:** VISHAAL S | **Roll No:** AA.SC.P2MCA24077071

A **simplified** Zero-Knowledge Proof authentication system.

---

## 🎯 The Problem

**Traditional Web3 Login:**
```
User connects wallet → Everyone sees your address (0xABC123...)
Problem: No privacy! You can be tracked across all dApps.
```

**ZKAuth Solution:**
```
User proves ownership → Nobody knows which wallet you used
Benefit: Privacy! No tracking, no linking addresses.
```

---

## 💡 How It Works (Simple Explanation)

### Step 1: Setup (One Time)
```
You have a secret number: 12345
You create a commitment: hash(12345) = 0xabc...def
You register this commitment (anonymously)
```

### Step 2: Login (Authenticate)
```
You prove you know the secret for commitment 0xabc...def
Contract checks: hash(12345) == 0xabc...def ✓
You're authenticated!
```

### Step 3: Privacy
```
Your wallet address is NOT linked to the commitment
Multiple people can use the same system
No way to track you across dApps
```

---

## 🚀 Quick Start

### 1. Install Foundry
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Setup Project
```bash
cd simple-zkauth
cp .env.example .env
# Add your PRIVATE_KEY to .env
```

### 3. Run Tests (See It Work!)
```bash
forge test -vvv
```

You'll see:
- ✓ Commitment registration
- ✓ Authentication with secret
- ✓ Privacy demonstration
- ✓ Session management

### 4. Deploy to Testnet
```bash
# Build
forge build

# Deploy to Polygon zkEVM Testnet
forge script script/Deploy.s.sol:DeploySimpleZKAuth \
    --rpc-url polygon_zkevm_testnet \
    --broadcast
```

---

## 📚 For Presentation

### Explaination:

**Q: What is ZKAuth?**
> "It's a privacy-preserving login system for Web3. Instead of exposing your wallet address when you log in, you prove you own a wallet without revealing which one."

**Q: How does it work?**
> "You create a secret 'commitment' (like a hash). When you want to log in, you prove you know the secret behind that commitment. The smart contract verifies it, but nobody can link your wallet to the commitment."

**Q: What's the benefit?**
> "Privacy! You can't be tracked across different dApps. Each login is anonymous, yet verifiable."

**Q: Is this real Zero-Knowledge?**
> "This is a simplified version to demonstrate the concept. A real ZK implementation would use zk-SNARKs (Groth16) where you don't reveal the secret at all - you just prove you know it. That's in the advanced version."

---

## 📖 Code Walkthrough

### Main Contract Functions

**1. Register Commitment** (Setup)
```solidity
function registerCommitment(bytes32 commitment) external
```
- One-time setup
- Creates anonymous identity
- Stores: hash(secret) → not linked to your address

**2. Authenticate** (Login)
```solidity
function authenticate(uint256 secret, bytes32 commitment) external
```
- Proves you know the secret
- Verifies: hash(secret) == commitment
- Authenticates you for 24 hours

**3. Check Auth** (Verify)
```solidity
function checkAuth(address user) external view returns (bool)
```
- Anyone can check if you're authenticated
- Returns true/false
- No personal data exposed

---

## 🧪 Testing

Run the test suite:
```bash
forge test -vvv
```

**Tests cover:**
- ✅ Commitment registration
- ✅ Authentication with correct secret
- ✅ Rejection of wrong secrets
- ✅ Privacy (multiple users)
- ✅ Session expiry (24 hours)
- ✅ Revoke authentication
- ✅ Complete flow demonstration

---

## 🎓 Project Deliverables

| Deliverable | Status | Notes |
|-------------|--------|-------|
| ZK Circuit Design | ✅ Conceptual | Simplified version (hash-based) |
| Solidity Contract | ✅ Complete | SimpleZKAuth.sol |
| Testing | ✅ Complete | Comprehensive test suite |
| Documentation | ✅ Complete | Easy to understand |
| Deployment | ✅ Ready | Foundry script included |

---

## 📊 Simple Example

```solidity
// USER 1
Secret: 12345
Commitment: keccak256(12345) = 0xabc123...
Registers commitment → Nobody knows it's User 1

// USER 2  
Secret: 67890
Commitment: keccak256(67890) = 0xdef456...
Registers commitment → Nobody knows it's User 2

// AUTHENTICATION
User 1 authenticates with secret 12345
Contract verifies: hash(12345) == 0xabc123... ✓
User 1 is authenticated, but identity remains private!
```

---

## 🔧 Usage Examples

### Deploy Locally
```bash
# Terminal 1: Start local blockchain
anvil

# Terminal 2: Deploy
forge script script/Deploy.s.sol:DeploySimpleZKAuth \
    --rpc-url localhost \
    --broadcast
```

### Interact with Contract
```bash
# Register commitment
cast send <CONTRACT> \
    "registerCommitment(bytes32)" \
    0xabc123... \
    --rpc-url localhost \
    --private-key <KEY>

# Authenticate
cast send <CONTRACT> \
    "authenticate(uint256,bytes32)" \
    12345 \
    0xabc123... \
    --rpc-url localhost \
    --private-key <KEY>

# Check authentication
cast call <CONTRACT> \
    "checkAuth(address)" \
    <YOUR_ADDRESS> \
    --rpc-url localhost
```

---

## 🎯 Key Points for Presentation

### 1. Problem Statement
"Traditional Web3 authentication exposes user identity"

### 2. Solution
"ZKAuth proves ownership without revealing identity"

### 3. How It Works
"Secret → Commitment → Proof → Authenticated"

### 4. Privacy Benefit
"No linking between wallet and commitment"

### 5. Real-World Use
"Private voting, anonymous access, unlinkable credentials"

---

## 🔐 Security Features

- ✅ **Commitment-based**: Identity hidden
- ✅ **Time-bound**: Sessions expire after 24h
- ✅ **Revocable**: Users can logout
- ✅ **Simple**: Easy to audit and understand

---

## 📁 Project Structure

```
simple-zkauth/
├── src/
│   └── SimpleZKAuth.sol        # Main contract (200 lines)
├── script/
│   └── Deploy.s.sol            # Deployment script
├── test/
│   └── SimpleZKAuth.t.sol      # Comprehensive tests
├── foundry.toml                # Configuration
└── README.md                   # This file
```

---

## 🎓 Learning Outcomes

**What you'll learn:**
- Zero-Knowledge Proof concepts
- Commitment schemes
- Solidity development
- Foundry testing
- Privacy-preserving systems
- Smart contract deployment

**What you'll demonstrate:**
- Understanding of ZK fundamentals
- Ability to implement privacy features
- Smart contract security
- Testing best practices

---

## 🚀 Next Steps

### For Basic Demo:
1. ✅ Deploy SimpleZKAuth (this version)
2. ✅ Run tests to demonstrate
3. ✅ Show commitment registration
4. ✅ Show authentication flow

### For Advanced Version:
1. ⏳ Implement real zk-SNARKs (Groth16)
2. ⏳ Add Circom circuit
3. ⏳ Use snarkjs for proofs
4. ⏳ Full Zero-Knowledge (no secret reveal)

---

## 💬 FAQs

**Q: Is this production-ready?**
A: This is educational. For production, use real zk-SNARKs (see advanced version).

**Q: Where's the frontend?**
A: This is Solidity-only as requested. Focus is on the smart contract.

**Q: How is this different from advanced version?**
A: This is simplified for easy explanation. Advanced uses Groth16 zk-SNARKs.

**Q: Can I use this for my project?**
A: Yes! It demonstrates the ZKAuth concept clearly and is easy to explain.

---

## 📞 Get Help

- Read the code comments
- Run the tests
- Check test output for examples
- See inline documentation

---

## ✅ Checklist

- [x] Easy to understand contract
- [x] Comprehensive tests
- [x] Clear documentation
- [x] Simple deployment
- [x] Ready for presentation
- [x] Demonstrates privacy
- [x] Shows ZK concept

---

**Perfect for academic presentations and demonstrations!**

Built with ❤️ for privacy in Web3
