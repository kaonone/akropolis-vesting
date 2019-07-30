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
    
    // MODIFIERS
    /**
    * @dev Allows to perform method by existing beneficiary
    */
    modifier onlyExistingBeneficiary(address _beneficiary) {
        require(isExistBeneficiary(_beneficiary), "address is not in beneficiary array");
        _;
    }

    /**
    * @dev Allows to perform method by pending beneficiary
    */

    modifier onlyPendingBeneficiary {
        require(msg.sender  == pendingBeneficiary, "Unpermitted operation.");
        _;
    }
     /**
        * @dev Allows beneficiaries to change beneficiaryShip and set first beneficiary as default
        * @param _newBeneficiaries defines array of addresses of new beneficiaries
        * @param _newHowManyBeneficiariesDecide defines how many beneficiaries can decide
    */
    
    function transferBeneficiaryShipWithHowMany(address[] memory _newBeneficiaries, uint256 _newHowManyBeneficiariesDecide) public  {
        super.transferBeneficiaryShipWithHowMany(_newBeneficiaries, _newHowManyBeneficiariesDecide);
        _setPendingBeneficiary(beneficiaries[0]);
    }

    /**
        * @dev Allows beneficiaries to change beneficiary as default
         * @param _newBeneficiary defines address of new beneficiary
    */
    function changeBeneficiary(address _newBeneficiary) public onlyManyBeneficiaries {
        _setPendingBeneficiary(_newBeneficiary);
    }

    /**
        * @dev Claim Beneficiary
    */
    function claimBeneficiary() public onlyPendingBeneficiary {
        super.changeBeneficiary(pendingBeneficiary);
        emit LogBeneficiaryTransfered(pendingBeneficiary);
        pendingBeneficiary = address(0);
    }

    /*
     * Internal Functions
     *
     */
    /**
        * @dev Set pending Beneficiary address
        * @param _newBeneficiary defines address of new beneficiary
    */
    function _setPendingBeneficiary(address _newBeneficiary) internal onlyExistingBeneficiary(_newBeneficiary) {
        pendingBeneficiary = _newBeneficiary;
        emit LogBeneficiaryTransferProposed(_newBeneficiary);
    }
}
