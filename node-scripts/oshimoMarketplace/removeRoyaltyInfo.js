const { initWallet, initContract } = require('../service/service.js');

async function main(uuid) {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.removeRoyaltyInfo(uuid);
  console.log(tx);
}

const uuid = 1;

main(uuid)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
