const Web3 = require('web3');

const {
  PRIVATE_KEY,
  NODE_URL,
  DEPLOYER_ADDRESS,
  USER1_ADDRESS,
  OSHIMO_NFT_CONTRACT_ADDRESS,
  NFT_CONTRACT_ABI,
} = require('../config/config.js').config;

const web3 = new Web3(new Web3.providers.HttpProvider(NODE_URL));

async function main(userAddress, tokenUri) {
  const count = await web3.eth.getTransactionCount(DEPLOYER_ADDRESS);

  console.log('count = ', count);

  const contract = await new web3.eth.Contract(
    NFT_CONTRACT_ABI,
    OSHIMO_NFT_CONTRACT_ADDRESS,
    { from: DEPLOYER_ADDRESS }
  );
  const dataRaw = await contract.methods
    .safeMint(userAddress, tokenUri)
    .encodeABI();

  console.log('dataRaw = ', dataRaw);

  const value = '0x0';

  const gasEstimate = await web3.eth.estimateGas({
    from: DEPLOYER_ADDRESS,
    nonce: '0x' + count.toString(16),
    to: userAddress,
    value: value,
    data: dataRaw,
  });

  console.log('gasEstimate = ', gasEstimate);

  var rawTx = {
    from: DEPLOYER_ADDRESS,
    nonce: web3.utils.toHex(count),
    gasPrice: await web3.utils.toHex(gasEstimate * 100000),
    gasLimit: await web3.utils.toHex(210000),
    to: userAddress,
    value: value,
    data: dataRaw,
  };

  console.log('rawTx = ', rawTx);

  const result_signTr = await web3.eth.accounts.signTransaction(
    rawTx,
    PRIVATE_KEY
  );
  console.log('result_signTr = ', result_signTr);

  const txId = await web3.eth.sendSignedTransaction(
    result_signTr.rawTransaction
  );

  console.log('txId = ', txId);
}

const userAddress = USER1_ADDRESS;
const tokenUri = 'test';

main(userAddress, tokenUri)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
