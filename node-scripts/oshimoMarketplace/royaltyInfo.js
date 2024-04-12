const { initWallet, initContract } = require('../service/service.js');

async function main(uuid, price) {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.royaltyInfo(uuid, price);
  console.log(tx);
}

const uuid = 1;
const price = 2;

main(uuid, price)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
