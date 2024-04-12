const hre = require('hardhat');

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  console.log('Account balance:', (await deployer.getBalance()).toString());

  const accessControllerAddress = '0x0;'

  const OshimoMarketplace = await hre.ethers.getContractFactory(
    'OshimoMarketplace'
  );
  const oshimoMarketplace = await OshimoMarketplace.deploy(
    accessControllerAddress,
    { gasPrice: hre.ethers.utils.parseUnits('50', 'gwei') }
  );
  await oshimoMarketplace.deployed();
  console.log(
    'oshimoMarketplace contract deployed to: ',
    oshimoMarketplace.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
