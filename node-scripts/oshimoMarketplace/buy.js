const Web3 = require('web3');
const ethers = require('ethers');

const { initWallet, initContract } = require('../service/service.js');

const { OSHIMO_NFT_CONTRACT_ADDRESS, USER1_PRIVATE_KEY } =
  require('../config/config.js').config;

async function main(contractAddress, uuid, price) {
  const wallet = await initWallet(USER1_PRIVATE_KEY);
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.buy(contractAddress, uuid, {
    from: wallet.address,
    value: ethers.utils.parseEther(price),
    gasLimit: Web3.utils.toHex(5000000),
  });
  console.log(tx);
}

const contractAddress = OSHIMO_NFT_CONTRACT_ADDRESS;
const uuid = 1;
const price = '2';

main(contractAddress, uuid, price)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
