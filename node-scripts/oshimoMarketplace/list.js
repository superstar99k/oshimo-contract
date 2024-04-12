const Web3 = require('web3');
const ethers = require('ethers');

const { initWallet, initContract } = require('../service/service.js');

const { OSHIMO_NFT_CONTRACT_ADDRESS, DEPLOYER_ADDRESS } =
  require('../config/config.js').config;

async function main(contractAddress, tokenId, price, receiver, percentage) {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  console.log(wallet.address);

  let tx = await oshimoMarketplace.list(
    contractAddress,
    tokenId,
    ethers.utils.parseEther(price),
    receiver,
    percentage,
    {
      from: wallet.address,
      value: ethers.utils.parseEther('0.0001'),
      gasLimit: Web3.utils.toHex(5000000),
    }
  );

  await tx.wait();

  console.log(tx);
}

const contractAddress = OSHIMO_NFT_CONTRACT_ADDRESS;
const tokenId = 1;
const price = '2';
const percentage = '10';
const receiver = DEPLOYER_ADDRESS;

main(contractAddress, tokenId, price, receiver, percentage)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
