# SimpleZKAuth - Quick Start Guide

Get started in 5 minutes!

---

## 📦 What You Need

- Foundry installed
- A wallet with testnet ETH
- 5 minutes

---

## 🚀 Installation

```bash
# 1. Install Foundry (if not already)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 2. Navigate to project
cd simple-zkauth

# 3. Setup environment
cp .env.example .env
# Edit .env and add your PRIVATE_KEY (without 0x)
```

---

## ✅ Test It Works

```bash
# Run tests to see it in action
forge test -vvv
```

You should see:
```
✓ Commitment registered successfully
✓ User authenticated successfully  
✓ Privacy achieved with multiple users
✓ Session management working
```

---

## 🌐 Deploy to Testnet

### Step 1: Get Testnet ETH

Visit: https://faucet.polygon.technology/
- Select "Polygon zkEVM Testnet (Cardona)"
- Enter your wallet address
- Get free testnet ETH

### Step 2: Build

```bash
forge build
```

### Step 3: Deploy

```bash
forge script script/Deploy.s.sol:DeploySimpleZKAuth \
    --rpc-url polygon_zkevm_testnet \
    --broadcast
```

**Save the contract address** from the output!

---

## 🎮 Try It Out

### Register a Commitment

```bash
# Your secret: 12345
# Commitment: keccak256(12345)

# Calculate commitment (use cast)
cast keccak $(cast abi-encode "f(uint256)" 12345)

# Register it
cast send <CONTRACT_ADDRESS> \
    "registerCommitment(bytes32)" \
    <YOUR_COMMITMENT> \
    --rpc-url polygon_zkevm_testnet \
    --private-key $PRIVATE_KEY
```

### Authenticate

```bash
cast send <CONTRACT_ADDRESS> \
    "authenticate(uint256,bytes32)" \
    12345 \
    <YOUR_COMMITMENT> \
    --rpc-url polygon_zkevm_testnet \
    --private-key $PRIVATE_KEY
```

### Check Authentication

```bash
cast call <CONTRACT_ADDRESS> \
    "checkAuth(address)" \
    <YOUR_ADDRESS> \
    --rpc-url polygon_zkevm_testnet
```

Should return: `0x0000000000000000000000000000000000000000000000000000000000000001` (true)

---

## 🎯 Simple Example

```solidity
// 1. Setup
Secret: 12345
Commitment: keccak256(abi.encodePacked(12345))

// 2. Register (one time)
registerCommitment(commitment)

// 3. Authenticate (login)
authenticate(12345, commitment)

// 4. Check
checkAuth(myAddress) → true ✓
```

---

## 📝 Common Commands

```bash
# Build
forge build

# Test
forge test -vvv

# Deploy locally
anvil                    # Terminal 1
forge script Deploy.s.sol --broadcast --rpc-url localhost  # Terminal 2

# Check gas usage
forge test --gas-report
```

---

## ❓ Troubleshooting

**"Insufficient funds"**
- Get testnet ETH from faucet

**"Build failed"**
```bash
forge clean
forge build
```

**"Tests not running"**
```bash
# Make sure you're in project directory
pwd  # Should show /path/to/simple-zkauth

# Install forge-std
forge install foundry-rs/forge-std --no-commit
```

---

## 🎓 For Your Presentation

**Run this during demo:**
```bash
forge test -vvv
```

The test output shows:
1. ✓ How commitments work
2. ✓ How authentication works
3. ✓ How privacy is maintained
4. ✓ Complete flow from start to finish

**Perfect for live demonstration!**

---

## 📚 Next Steps

1. ✅ Run tests - see it work
2. ✅ Deploy to testnet
3. ✅ Interact with contract
4. ✅ Read the code comments
5. ✅ Prepare presentation using PRESENTATION_GUIDE.md

---

**You're all set! 🎉**

Need help? Check:
- README.md - Full documentation
- PRESENTATION_GUIDE.md - How to present this
- Test file - Working examples
