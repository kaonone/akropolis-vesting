pragma solidity ^0.5.0;

//Import Upgradeability Template
import "zos-lib/contracts/upgradeability/UpgradeabilityProxy.sol";

//Timelock Template
import 'openzeppelin-solidity/contracts/token/ERC20/TokenTimelock.sol';

//Beneficieries template
import "../helpers/BeneficiaryOperations.sol";


/**
* @title TimelockProxy
* @notice A proxy contract that serves the latest implementation of TimelockProxy.
*/

contract TimelockProxy is UpgradeabilityProxy, TokenTimelock, BeneficiaryOperations {


    constructor (ddress _implementation, IERC20 _token, address _beneficiary, uint256 _releaseTime)
        UpgradeabilityProxy(_implementation) 
        TokenTimelock(_token, _beneficiary, _releaseTime) public  {} 
    

    /**
    * @dev Upgrade the backing implementation of the proxy.
    * Only the admin can call this function.
    * @param newImplementation Address of the new implementation.
    */
    function upgradeTo(address newImplementation) public {
        _upgradeTo(newImplementation);
    }

    /**
    * @return The address of the implementation.
    */
    function implementation() public view returns (address) {
        return _implementation();
    }
}


