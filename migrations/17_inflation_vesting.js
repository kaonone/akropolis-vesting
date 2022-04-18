var AkropolisTokenVesting = artifacts.require('./AkropolisTokenVesting.sol');

module.exports = async function (deployer, network, accounts) {
  const owner = accounts[0];

  const token =
    network === 'mainnet'
      ? '0x8ab7404063ec4dbcfd4598215992dc3f8ec853d7'
      : '0xcbB03b0247688552ca34a4cE910b3254A420c523';
  const start = 1640995200; // 01.01.2022
  const cliffDuration = 0;
  const duration = 157766399; // 31.12.2026 - 01.01.2022

  console.log('owner of storage contracts: ' + owner);

  await deployer.deploy(AkropolisTokenVesting, token, start, cliffDuration, duration, {
    from: owner,
  });
};
