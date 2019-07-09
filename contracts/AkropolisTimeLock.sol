pragma solidity ^0.5.0;
import 'openzeppelin-solidity/contracts/token/ERC20/TokenTimelock.sol';

contract AkropolisVesting is TokenTimelock {

        /**
        * @notice Constructor.
        * @param _token  Address of AKRO token
        * @param _beneficiary Beneficiary address
        * @param _releaseTime Timestamp date
        */

        constructor (IERC20 _token, address _beneficiary, uint256 _releaseTime) public
            TokenTimelock(_token, _beneficiary, _releaseTime) {}   

        modifier onlyBeneficiary() {
            require(isBeneficiary(), "Sender is not beneficiary");
            _;
        }

        function isBeneficiary() public view returns (bool) {
            return msg.sender == beneficiary();
        }

        function release() public onlyBeneficiary {
            super.release();
        }  
}