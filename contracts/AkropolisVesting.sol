pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/drafts/TokenVesting.sol';

contract AkropolisVesting is TokenVesting {

    IERC20 private token;

    constructor (IERC20 _token, address _beneficiary, uint256 _start, uint256 _cliffDuration, uint256 _duration, bool _revocable) public 
        TokenVesting(_beneficiary, _start, _cliffDuration, _duration, _revocable) {
            token = _token;
    }


     /**
     * @notice Transfers vested tokens to beneficiary.
     */

    function release() public {
        super.release(token);
    }

    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     */

    function revoke() public {
        super.revoke(token);
    }
}
