const ethers = require('ethers');

const {
  PRIVATE_KEY,
  NODE_URL,
  OSHIMO_NFT_MARKETPLACE_CONTRACT_ADDRESS,
  ACCESS_CONTROLLER_CONTRACT_ADDRESS,
  OSHIMO_NFT_CONTRACT_ADDRESS,
  OSHIMO_NFT_MARKETPLACE_ABI,
  ACCESS_CONTROLLER_ABI,
  NFT_CONTRACT_ABI,
} = require('../config/config.js').config;

async function initWallet(prvKey = PRIVATE_KEY) {
  const HTTPSProvider = new ethers.providers.JsonRpcProvider(NODE_URL);

  return await new ethers.Wallet(prvKey, HTTPSProvider);
}

async function initOshimoMarketplace(wallet) {
  return await new ethers.Contract(
    OSHIMO_NFT_MARKETPLACE_CONTRACT_ADDRESS,
    OSHIMO_NFT_MARKETPLACE_ABI,
    wallet
  );
}

async function initOshimoNFT(wallet) {
  return await new ethers.Contract(
    OSHIMO_NFT_CONTRACT_ADDRESS,
    NFT_CONTRACT_ABI,
    wallet
  );
}

async function initAccessController(wallet) {
  return await new ethers.Contract(
    ACCESS_CONTROLLER_CONTRACT_ADDRESS,
    ACCESS_CONTROLLER_ABI,
    wallet
  );
}

async function initContract(wallet) {
  const oshimoMarketplace = await initOshimoMarketplace(wallet);
  const accessController = await initAccessController(wallet);
  const oshimoNFT = await initOshimoNFT(wallet);

  return { oshimoMarketplace, accessController, oshimoNFT };
}

module.exports = {
  initWallet,
  initContract,
};
