const Web3 = require('web3');
const ethers = require('ethers');

const { initWallet, initContract } = require('../service/service.js');

async function main(amount) {
  const wallet = await initWallet();
  const { oshimoMarketplace } = await initContract(wallet);

  let tx = await oshimoMarketplace.setFee(amount, {
    from: wallet.address,
    gasLimit: Web3.utils.toHex(5000000),
  });

  console.log(tx);
}

const amount = ethers.utils.parseEther('0.0001');

main(amount)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
