var AkropolisTokenVesting= artifacts.require("./AkropolisTokenVesting.sol");


module.exports = function(deployer, network, accounts) {
  let owner = accounts[0];
  
  let token = "0x8ab7404063ec4dbcfd4598215992dc3f8ec853d7"; //AKRO
  let start = 1640970000; // 01.01.2022
  let cliffDuration = 0;
  let duration = 157680000; // 31.12.2026 - 01.01.2022

  //console.log('owner of storage contracts: ' + owner)

  deployer.deploy(AkropolisTokenVesting, token, start, cliffDuration, duration, {from: owner});
  
};

