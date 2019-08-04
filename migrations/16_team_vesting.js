var AkropolisTokenVesting= artifacts.require("./AkropolisTokenVesting.sol");


module.exports = function(deployer, network, accounts) {
  let owner = accounts[0];
  
  let token = "0x8ab7404063ec4dbcfd4598215992dc3f8ec853d7"; //AKRO
  let start = 1592265660; // 16.07.2020
  let cliffDuration = 2592000; //30 days
  let duration = 60480000; //700 days

  //console.log('owner of storage contracts: ' + owner)

  deployer.deploy(AkropolisTokenVesting, token, start, cliffDuration, duration, {from: owner});
  
};

