const { initWallet, initContract } = require('../service/service.js');

async function main(id) {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.getNftById(id);
  console.log(tx);
}

const id = 1;

main(id)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
