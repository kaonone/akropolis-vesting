const { toSeconds } = require('./helpers/toSeconds');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

const AkropolisTokenVesting = artifacts.require('AkropolisTokenVesting.sol');

contract('AkropolisTokenVesting', function ([_, wallet1, wallet2, wallet3]) {
  const token = '0xC4375B7De8af5a38a93548eb8453a498222C4fF2';
  const start = toSeconds('2022-01-01');
  const cliffDuration = toSeconds('2022-01-03') - start;
  const duration = toSeconds('2025-01-01') - start;

  it('should be initialized correctly', async function () {
    const obj = await AkropolisTokenVesting.new(token, start, cliffDuration, duration);

    (await obj.beneficiaries.call(0)).should.be.equal(_);
    (await obj.beneficiariesCount.call()).toNumber().should.be.equal(1);

    (await obj.isExistBeneficiary.call(_)).should.be.true;
    (await obj.isExistBeneficiary.call(wallet1)).should.be.false;

    (await obj.beneficiary.call()).should.be.equal(_);
  });

  it('should transfer beneficiary correctly 2 => 1', async function () {
    const obj = await AkropolisTokenVesting.new(token, start, cliffDuration, duration);

    await obj.transferBeneficiaryShip([wallet1, wallet2]);

    (await obj.beneficiaries.call(0)).should.be.equal(wallet1);
    (await obj.beneficiaries.call(1)).should.be.equal(wallet2);

    await obj.claimBeneficiary({ from: wallet1 });

    (await obj.beneficiary.call()).should.be.equal(wallet1);
  });

  it('should change beneficiary  correctly 2 => 2', async function () {
    const obj = await AkropolisTokenVesting.new(token, start, cliffDuration, duration);

    await obj.transferBeneficiaryShip([wallet1, wallet2]);
    (await obj.pendingBeneficiary.call()).should.be.equal(wallet1);
    await obj.claimBeneficiary({ from: wallet1 });
    (await obj.beneficiary.call()).should.be.equal(wallet1);

    (await obj.beneficiaries.call(0)).should.be.equal(wallet1);
    (await obj.beneficiaries.call(1)).should.be.equal(wallet2);

    (await obj.beneficiariesCount.call()).toNumber().should.be.equal(2);

    await obj.changeBeneficiary(wallet2, { from: wallet1 });

    await obj.changeBeneficiary(wallet2, { from: wallet2 });
    (await obj.pendingBeneficiary.call()).should.be.equal(wallet2);

    await obj.claimBeneficiary({ from: wallet2 });

    (await obj.beneficiary.call()).should.be.equal(wallet2);
  });

  it('should change beneficiary  correctly 3 => 3', async function () {
    const obj = await AkropolisTokenVesting.new(token, start, cliffDuration, duration);

    await obj.transferBeneficiaryShip([wallet1, wallet2, wallet3]);
    (await obj.pendingBeneficiary.call()).should.be.equal(wallet1);
    await obj.claimBeneficiary({ from: wallet1 });
    (await obj.beneficiary.call()).should.be.equal(wallet1);

    (await obj.beneficiaries.call(0)).should.be.equal(wallet1);
    (await obj.beneficiaries.call(1)).should.be.equal(wallet2);
    (await obj.beneficiaries.call(2)).should.be.equal(wallet3);

    (await obj.beneficiariesCount.call()).toNumber().should.be.equal(3);

    await obj.changeBeneficiary(wallet2, { from: wallet1 });
    await obj.changeBeneficiary(wallet2, { from: wallet2 });
    await obj.changeBeneficiary(wallet2, { from: wallet3 });
    (await obj.pendingBeneficiary.call()).should.be.equal(wallet2);

    await obj.claimBeneficiary({ from: wallet2 });

    (await obj.beneficiary.call()).should.be.equal(wallet2);
  });

  it('should change beneficiary  correctly 3 => 2', async function () {
    const obj = await AkropolisTokenVesting.new(token, start, cliffDuration, duration);

    await obj.transferBeneficiaryShipWithHowMany([wallet1, wallet2, wallet3], 2);
    (await obj.pendingBeneficiary.call()).should.be.equal(wallet1);
    await obj.claimBeneficiary({ from: wallet1 });
    (await obj.beneficiary.call()).should.be.equal(wallet1);

    (await obj.beneficiaries.call(0)).should.be.equal(wallet1);
    (await obj.beneficiaries.call(1)).should.be.equal(wallet2);
    (await obj.beneficiaries.call(2)).should.be.equal(wallet3);

    (await obj.beneficiariesCount.call()).toNumber().should.be.equal(3);

    await obj.changeBeneficiary(wallet2, { from: wallet1 });
    await obj.changeBeneficiary(wallet2, { from: wallet3 });
    (await obj.pendingBeneficiary.call()).should.be.equal(wallet2);

    await obj.claimBeneficiary({ from: wallet2 });

    (await obj.beneficiary.call()).should.be.equal(wallet2);
  });
});
