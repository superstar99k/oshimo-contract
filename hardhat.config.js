require('dotenv').config();
require('@nomiclabs/hardhat-waffle');
const fs = require('fs');
const projectId = process.env.PROJECT_ID;
const privateKey = process.env.PRIVATE_KEY;

module.exports = {
  defaultNetwork: 'hardhat',
  networks: {
    local: {
      chainId: 31337,
      url: 'http://127.0.0.1:8545/',
      account: [privateKey],
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
      account: [privateKey],
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${projectId}`,
      account: [privateKey],
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${projectId}`,
      account: [privateKey],
    },
    mychain: {
      url: `http://35.74.70.3:8551/`,
      account: [privateKey],
    },
  },

  solidity: {
    version: '0.8.13',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
