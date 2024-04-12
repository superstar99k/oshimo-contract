const Web3 = require('web3');

const { initWallet, initContract } = require('./service/service.js');

async function main() {
  console.log('setup access control');
  const wallet = await initWallet();
  const { oshimoMarketplace, accessController, oshimoNFT } = await initContract(
    wallet
  );

  await accessController.bulkSetupRole(
    [
      await oshimoNFT.NFT_MINTER_ROLE(),
      await oshimoMarketplace.NFT_ACCESS_ROLE(),
      await oshimoMarketplace.NFT_MINTER_ROLE(),
    ],
    wallet.address,
    {
      from: wallet.address,
      gasLimit: Web3.utils.toHex(5000000),
    }
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
