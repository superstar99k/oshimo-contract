const { initWallet, initContract } = require('../service/service.js');

const { PRIVATE_KEY } = require('../config/config.js').config;

async function main(tokenId, price) {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.createOshimoNft(tokenId, price, {
    from: wallet.address,
    value: 0,
    gasLimit: Web3.utils.toHex(5000000),
  });

  console.log(tx);
}

const tokenId = 1;
const price = 100;

main(tokenId, price);
