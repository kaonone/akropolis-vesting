var AkropolisVesting = artifacts.require("./AkropolisVesting.sol");


//Community, Bounty, Marketing

module.exports = function(deployer, network, accounts) {
    let owner = accounts[0];

    //mock data
    let beneficiary = '0x2188eafbe04f79e1fc89a8191a816fc2bd514f89';
    let start = 1563321600;
    let cliff = 315360;
    let duration = 31536000;
    console.log('owner of token contracts: ' + owner)
    deployer.deploy(AkropolisVesting, beneficiary, start, cliff, duration, false, {from:owner});
};
