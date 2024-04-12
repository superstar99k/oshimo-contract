const ethers = require('ethers');

const { initWallet, initContract } = require('../service/service.js');

async function main(uuid) {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.getTokenId(uuid);
  console.log(tx);
  console.log(ethers.utils.formatEther(tx) * 10 ** 18);
}

const uuid = 1;

main(uuid)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
