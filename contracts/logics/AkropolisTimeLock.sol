pragma solidity ^0.5.0;
import '../openzeppelin/TokenTimelock.sol';

//Beneficieries template
import "../helpers/BeneficiaryOperations.sol";

contract AkropolisTimeLock is TokenTimelock, BeneficiaryOperations {

        /**
        * @notice Constructor.
        * @param _token  Address of AKRO token
        * @param _beneficiary Beneficiary address
        * @param _releaseTime Timestamp date
        */

        constructor (IERC20 _token, address _beneficiary, uint256 _releaseTime) public
            TokenTimelock(_token, _beneficiary, _releaseTime) {}  


         /**
            * @dev Allows beneficiaries to change beneficiaryShip and set first beneficiary as default
            * @param newBeneficiaries defines array of addresses of new beneficiaries
            * @param newHowManyBeneficiariesDecide defines how many beneficiaries can decide
        */
        function transferBeneficiaryShipWithHowMany(address[] memory newBeneficiaries, uint256 newHowManyBeneficiariesDecide) public onlyManyBeneficiaries {
            super.transferBeneficiaryShipWithHowMany(newBeneficiaries, newHowManyBeneficiariesDecide);
            super.changeBeneficiary(beneficiaries[1]);
        }
}