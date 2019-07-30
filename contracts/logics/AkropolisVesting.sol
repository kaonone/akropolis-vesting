pragma solidity ^0.5.0;

import '../openzeppelin/TokenVesting.sol';

//Beneficieries template
import "../helpers/BeneficiaryOperations.sol";

contract AkropolisVesting is TokenVesting, BeneficiaryOperations {

    IERC20 private token;

    address private pendingBeneficiary;

    event LogBeneficiaryTransferProposed(address _beneficiary);
    event LogBeneficiaryTransfered(address _beneficiary);

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
        * @dev Allows beneficiaries to change beneficiaryShip and set first beneficiary as default
        * @param _newBeneficiaries defines array of addresses of new beneficiaries
        * @param _newHowManyBeneficiariesDecide defines how many beneficiaries can decide
    */
    
    function transferBeneficiaryShipWithHowMany(address[] memory _newBeneficiaries, uint256 _newHowManyBeneficiariesDecide) public  {
        super.transferBeneficiaryShipWithHowMany(_newBeneficiaries, _newHowManyBeneficiariesDecide);
        changeBeneficiary(beneficiaries[0]);
    }

    /**
        * @dev Allows beneficiaries to change beneficiary as default
         * @param _newBeneficiary defines address of new beneficiary
    */
    function changeBeneficiary(address _newBeneficiary) public onlyManyBeneficiaries {
        require(isExistBeneficiary(_newBeneficiary), "address is not in beneficiary array");
        _setPendingBeneficiary(_newBeneficiary);
        emit LogBeneficiaryTransferProposed(_newBeneficiary);
    }

    /**
        * @dev Set pending Beneficiary address
        * @param _newBeneficiary defines address of new beneficiary
    */
    function _setPendingBeneficiary(address _newBeneficiary) internal {
        require(_newBeneficiary  != address(0), "Invalid address.");
        pendingBeneficiary = _newBeneficiary;
    }

    /**
        * @dev Claim Beneficiary
    */
    function claimBeneficiary() public {
        require(msg.sender  == pendingBeneficiary, "Unpermitted operation.");
        super.changeBeneficiary(pendingBeneficiary);
        emit LogBeneficiaryTransfered(pendingBeneficiary);
        pendingBeneficiary = address(0);
    }
}
