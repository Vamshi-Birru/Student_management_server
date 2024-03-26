const hre = require("hardhat");
const { ethers } = require("hardhat");
const fs = require('fs');
const path = require('path');
const http = require('http');
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying Agent contract with the account:", deployer.address);

  try {
    const Agent = await ethers.getContractFactory("Agent");
    const agent = await Agent.deploy();

    console.log("Agent contract deployed to:", agent.target);
    fs.writeFileSync(path.join(__dirname, 'contractAddress.json'), JSON.stringify(agent.target));

    // Write ABI to a file
    fs.writeFileSync(path.join(__dirname, 'contractABI.json'), JSON.stringify(Agent.interface));
   
  } catch (error) {
    console.error("Error deploying Agent contract:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error("Error in main function:", error);
    process.exit(1);
  });

  