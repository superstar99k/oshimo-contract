const { initWallet, initContract } = require('../service/service.js');

async function main() {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.getListedNfts();
  console.log(tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
