var AkropolisTokenVesting = artifacts.require('./AkropolisTokenVesting.sol');

module.exports = async function (deployer, network, accounts) {
  const owner = accounts[0];

  const token =
    network === 'mainnet'
      ? '0x8ab7404063ec4dbcfd4598215992dc3f8ec853d7'
      : '0xcbB03b0247688552ca34a4cE910b3254A420c523';
  const start = 1719964800; // 2024-07-03T00:00:00.000Z
  const cliffDuration = 0;
  const duration = 126230400; // 2028-07-03T00:00:00.000Z - 2024-07-03T00:00:00.000Z

  console.log('owner of storage contracts: ', owner);

  await deployer.deploy(AkropolisTokenVesting, token, start, cliffDuration, duration, {
    from: owner,
  });
};

// commands:
// truffle migrate --f 19 --network mainnet
// truffle run verify AkropolisTokenVesting@0xc04...70f --network mainnet --verifiers=etherscan
