var AkropolisVesting = artifacts.require("./AkropolisVesting.sol");


module.exports = function(deployer, network, accounts) {
    let owner = accounts[0];
    let beneficiary = "0x0a59e9a535e179cf524440ebe34cf820e1e5ff68b139ac314f0b53cab3dabf57";
    let start = 0;
    let cliff = 0;
    let duration = 0;
    console.log('owner of token contracts: ' + owner)
    deployer.deploy(AkropolisVesting, beneficiary, start, cliff, duration, false, {from:owner});
};
