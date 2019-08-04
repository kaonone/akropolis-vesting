var AkropolisTokenVesting= artifacts.require("./AkropolisTokenVesting.sol");


module.exports = function(deployer, network, accounts) {
  let owner = accounts[0];
  
  let token = "0xC4375B7De8af5a38a93548eb8453a498222C4fF2";
  let start = 1564740000;
  let cliffDuration = 1800;
  let duration = 7200;

  //console.log('owner of storage contracts: ' + owner)

  deployer.deploy(AkropolisTokenVesting, token, start, cliffDuration, duration, {from: owner});
  
};

