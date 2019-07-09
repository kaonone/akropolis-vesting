pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/drafts/TokenVesting.sol';

contract AkropolisVesting is TokenVesting {


    constructor (address _beneficiary, uint256 _start, uint256 _cliffDuration, uint256 _duration, bool _revocable) public 
        TokenVesting(_beneficiary, _start, _cliffDuration, _duration, _revocable) {}

    
    modifier onlyBeneficiary() {
        require(isBeneficiary(), "Sender is not beneficiary");
        _;
    }


    function isBeneficiary() public view returns (bool) {
        return msg.sender == beneficiary();
    }

    function release(IERC20 token) public  onlyBeneficiary {
        super.release(token);
    }


}
