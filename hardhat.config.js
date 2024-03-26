require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  paths:{
    artifacts:"./artifacts",
  },
  network:{
    hardhat:{
      chainId: 31337,
    }
  },
  
  
};
