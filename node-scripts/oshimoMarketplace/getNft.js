const { initWallet, initContract } = require('../service/service.js');

const { OSHIMO_NFT_MARKETPLACE_CONTRACT_ADDRESS } =
  require('../config/config.js').config;

async function main() {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.getNft(
    OSHIMO_NFT_MARKETPLACE_CONTRACT_ADDRESS,
    1
  );
  console.log(tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
