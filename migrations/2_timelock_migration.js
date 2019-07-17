var AkropolisTimeLock = artifacts.require("./AkropolisTimeLock.sol");


module.exports = function(deployer, network, accounts) {
  let owner = accounts[0];
  
  let token = "0x32C9F8E8AFA287936307241b9683E998dfDC92dd";
  let beneficiary = "0x6C07300884d531dDeAC2A39B8BF19f995b6632f5";
  let releaseDate = 1564520400;

  console.log('owner of storage contracts: ' + owner)


  deployer.deploy(AkropolisTimeLock, token, beneficiary, releaseDate, {from: owner});
  
};
