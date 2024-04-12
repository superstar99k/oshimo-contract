const Web3 = require('web3');

const { initWallet, initContract } = require('../service/service.js');

const { DEPLOYER_ADDRESS } = require('../../config/config.js').config;

async function main(tokenUri, price, receiver, percentage) {
  const wallet = await initWallet();
  const { oshimoNFT } = await initContract(wallet);

  const tx = await oshimoNFT.lazyMint(tokenUri, price, receiver, percentage, {
    from: wallet.address,
    gasLimit: Web3.utils.toHex(5000000),
  });

  await tx.wait();

  console.log(tx);
  return tx;
}

const tokenUri = 'test';
const price = '2';
const percentage = '10';
const receiver = DEPLOYER_ADDRESS;

main(tokenUri, price, receiver, percentage)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
