const { initWallet, initContract } = require('../service/service.js');

const { USER1_ADDRESS, OSHIMO_NFT_MARKETPLACE_CONTRACT_ADDRESS } =
  require('../config/config.js').config;

async function main(address) {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.getNftsByHolder(address);
  console.log(tx);
}

const address = OSHIMO_NFT_MARKETPLACE_CONTRACT_ADDRESS;

main(address)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
