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

async function sleep(ms) {
  return await new Promise((resolve) => setTimeout(resolve, ms));
}

async function run() {
  const contractAddress = OSHIMO_NFT_CONTRACT_ADDRESS;
  const price = '2';
  const percentage = '10';
  const receiver = DEPLOYER_ADDRESS;

  for (let i = 0; i < 5; i++) {
    await sleep(1000);
    main(contractAddress, i + 1, price, receiver, percentage);
  }
}

run()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
