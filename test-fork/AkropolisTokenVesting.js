import increaseTime from '../test/helpers/increaseTime';

const AkropolisTokenVesting = artifacts.require('AkropolisTokenVesting.sol');

require('chai').should();

contract('AkropolisTokenVesting', (accounts) => {
  const akroToken = '0xcbB03b0247688552ca34a4cE910b3254A420c523';
  const multisig = '0xA5947832E55D150B9d1BAB59126Fda9830fcd993';
  const start = 1640995200; // 01.01.2022
  const duration = 157766399; // 31.12.2026 - 01.01.2022
  const initialOwner = accounts[0];
  const amount = web3.utils.toWei('1000000000');
  const tokenContract = new web3.eth.Contract(
    [
      {
        name: 'mint',
        inputs: [
          { name: '_to', type: 'address' },
          { name: '_amount', type: 'uint256' },
        ],
        outputs: [],
        type: 'function',
      },
      {
        name: 'mintStarted',
        inputs: [],
        outputs: [],
        type: 'function',
      },
      {
        name: 'balanceOf',
        inputs: [{ name: 'who', type: 'address' }],
        outputs: [{ name: '', type: 'uint256' }],
        type: 'function',
      },
    ],
    akroToken
  );

  let vesting;

  before(async () => {
    vesting = await AkropolisTokenVesting.deployed();
    await web3.eth.sendTransaction({
      from: accounts[0],
      to: multisig,
      value: web3.utils.toWei('100'),
    });
  });

  it('should be initialized correctly', async () => {
    (await vesting.beneficiariesCount()).toNumber().should.be.equal(1);
    (await vesting.beneficiary()).toLowerCase().should.equal(initialOwner.toLowerCase());
    (await vesting.start()).toNumber().should.equal(start);
    (await vesting.cliff()).toNumber().should.equal(start);
    (await vesting.duration()).toNumber().should.equal(duration);
    (await vesting.tokenAddress()).toLowerCase().should.equal(akroToken.toLowerCase());
  });

  it('should transfer beneficiaryship', async () => {
    await vesting.transferBeneficiaryShip([multisig], { from: initialOwner });
    await vesting.claimBeneficiary({ from: multisig });

    (await vesting.beneficiariesCount()).toNumber().should.equal(1);
    (await vesting.beneficiaries(0)).toLowerCase().should.equal(multisig.toLowerCase());
  });

  it('should transfer ownership to multisig', async () => {
    await vesting.transferOwnership(multisig, { from: initialOwner });
    (await vesting.owner()).toLowerCase().should.equal(multisig.toLowerCase());
    (await vesting.isOwner({ from: initialOwner })).should.equal(false);
  });

  it('should receive AKRO tokens', async () => {
    await tokenContract.methods.mintStarted().send({ from: multisig });
    await tokenContract.methods.mint(vesting.address, amount).send({ from: multisig });
    (await tokenContract.methods.balanceOf(vesting.address).call()).toString().should.equal(amount);
  });

  it('should release some amount to the vesting contract', async function () {
    const { logs } = await vesting.release(akroToken, { from: multisig });
    logs[0].event.should.equal('TokensReleased');
    const releasedAmount = await vesting.released(akroToken);
    const multisigBalance = await tokenContract.methods.balanceOf(multisig).call();
    releasedAmount.toString().should.equal(multisigBalance.toString());
  });

  it('should release full amount when duration is over', async function () {
    await increaseTime(duration);
    await vesting.release(akroToken, { from: multisig });
    const multisigBalance = (await tokenContract.methods.balanceOf(multisig).call()).toString();
    multisigBalance.should.equal(amount);
  });
});
