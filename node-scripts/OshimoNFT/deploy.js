const hre = require('hardhat');

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  console.log('Account balance:', (await deployer.getBalance()).toString());

  const accessControllerAddress = '0x0;'
  const oshimoMarketplaceAddress = '0x0;'

  const OshimoNFT = await hre.ethers.getContractFactory('OshimoNFT');
  const oshimoNFT = await OshimoNFT.deploy(
    accessControllerAddress,
    'TEST',
    'T',
    oshimoMarketplaceAddress,
    'https://initbaseuri.json/',
    { gasPrice: hre.ethers.utils.parseUnits('50', 'gwei') }
  );
  await oshimoNFT.deployed();
  console.log('OshimoNFT contract deployed to: ', oshimoNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
