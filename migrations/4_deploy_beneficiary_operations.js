const BeneficiaryOperations = artifacts.require('BeneficiaryOperations');

module.exports = function (deployer) {
    deployer.deploy(BeneficiaryOperations);
};
