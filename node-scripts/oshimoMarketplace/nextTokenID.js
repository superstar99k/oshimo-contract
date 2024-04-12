const ethers = require('ethers');

const { initWallet, initContract } = require('../service/service.js');

async function main() {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.nextTokenID();
  console.log(tx);
  console.log(ethers.utils.formatEther(tx) * 10 ** 18);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
