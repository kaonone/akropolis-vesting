/*var AkropolisTimeLock = artifacts.require("./AkropolisTimeLock.sol");


module.exports = function(deployer, network, accounts) {
  let owner = accounts[0];
  
  let token = "0xC4375B7De8af5a38a93548eb8453a498222C4fF2";
  let releaseDate = 1564661195;

  console.log('owner of storage contracts: ' + owner)

  deployer.deploy(AkropolisTimeLock, token, releaseDate, {from: owner});
  
};*/

const BeneficiaryOperations = artifacts.require('BeneficiaryOperations');

module.exports = function (deployer) {
    deployer.deploy(BeneficiaryOperations);
};

