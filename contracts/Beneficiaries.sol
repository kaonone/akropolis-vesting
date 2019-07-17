pragma solidity ^0.5.0;


contract Beneficiaries {

    // VARIABLES

    uint256 public beneficiarysGeneration;
    uint256 public howManybeneficiarysDecide;
    address[] public beneficiarys;
    bytes32[] public allOperations;
    address internal insideCallSender;
    uint256 internal insideCallCount;

    // Reverse lookup tables for beneficiarys and allOperations
    mapping(address => uint) public beneficiarysIndices; // Starts from 1
    mapping(bytes32 => uint) public allOperationsIndicies;

    // beneficiarys voting mask per operations
    mapping(bytes32 => uint256) public votesMaskByOperation;
    mapping(bytes32 => uint256) public votesCountByOperation;

    // EVENTS

    event beneficiaryShipTransferred(address[] previousbeneficiarys, uint howManybeneficiarysDecide, address[] newbeneficiarys, uint newHowManybeneficiarysDecide);
    event OperationCreated(bytes32 operation, uint howMany, uint beneficiarysCount, address proposer);
    event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint beneficiarysCount, address upvoter);
    event OperationPerformed(bytes32 operation, uint howMany, uint beneficiarysCount, address performer);
    event OperationDownvoted(bytes32 operation, uint votes, uint beneficiarysCount,  address downvoter);
    event OperationCancelled(bytes32 operation, address lastCanceller);
    
    // ACCESSORS

    function isbeneficiary(address wallet) public constant returns(bool) {
        return beneficiarysIndices[wallet] > 0;
    }

    function beneficiarysCount() public constant returns(uint) {
        return beneficiarys.length;
    }

    function allOperationsCount() public constant returns(uint) {
        return allOperations.length;
    }

    // MODIFIERS

    /**
    * @dev Allows to perform method by any of the beneficiarys
    */
    modifier onlyAnybeneficiary {
        if (checkHowManybeneficiarys(1)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = 1;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
    * @dev Allows to perform method only after many beneficiarys call it with the same arguments
    */
    modifier onlyManybeneficiarys {
        if (checkHowManybeneficiarys(howManybeneficiarysDecide)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howManybeneficiarysDecide;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
    * @dev Allows to perform method only after all beneficiarys call it with the same arguments
    */
    modifier onlyAllbeneficiarys {
        if (checkHowManybeneficiarys(beneficiarys.length)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = beneficiarys.length;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
    * @dev Allows to perform method only after some beneficiarys call it with the same arguments
    */
    modifier onlySomebeneficiarys(uint howMany) {
        require(howMany > 0, "onlySomebeneficiarys: howMany argument is zero");
        require(howMany <= beneficiarys.length, "onlySomebeneficiarys: howMany argument exceeds the number of beneficiarys");
        
        if (checkHowManybeneficiarys(howMany)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howMany;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    // CONSTRUCTOR

    constructor() public {
        beneficiarys.push(msg.sender);
        beneficiarysIndices[msg.sender] = 1;
        howManybeneficiarysDecide = 1;
    }

    // INTERNAL METHODS

    /**
     * @dev onlyManybeneficiarys modifier helper
     */
    function checkHowManybeneficiarys(uint howMany) internal returns(bool) {
        if (insideCallSender == msg.sender) {
            require(howMany <= insideCallCount, "checkHowManybeneficiarys: nested beneficiarys modifier check require more beneficiarys");
            return true;
        }

        uint beneficiaryIndex = beneficiarysIndices[msg.sender] - 1;
        require(beneficiaryIndex < beneficiarys.length, "checkHowManybeneficiarys: msg.sender is not an beneficiary");
        bytes32 operation = keccak256(msg.data, beneficiarysGeneration);

        require((votesMaskByOperation[operation] & (2 ** beneficiaryIndex)) == 0, "checkHowManybeneficiarys: beneficiary already voted for the operation");
        votesMaskByOperation[operation] |= (2 ** beneficiaryIndex);
        uint operationVotesCount = votesCountByOperation[operation] + 1;
        votesCountByOperation[operation] = operationVotesCount;
        if (operationVotesCount == 1) {
            allOperationsIndicies[operation] = allOperations.length;
            allOperations.push(operation);
            emit OperationCreated(operation, howMany, beneficiarys.length, msg.sender);
        }
        emit OperationUpvoted(operation, operationVotesCount, howMany, beneficiarys.length, msg.sender);

        // If enough beneficiarys confirmed the same operation
        if (votesCountByOperation[operation] == howMany) {
            deleteOperation(operation);
            emit OperationPerformed(operation, howMany, beneficiarys.length, msg.sender);
            return true;
        }

        return false;
    }

    /**
    * @dev Used to delete cancelled or performed operation
    * @param operation defines which operation to delete
    */
    function deleteOperation(bytes32 operation) internal {
        uint index = allOperationsIndicies[operation];
        if (index < allOperations.length - 1) { // Not last
            allOperations[index] = allOperations[allOperations.length - 1];
            allOperationsIndicies[allOperations[index]] = index;
        }
        allOperations.length--;

        delete votesMaskByOperation[operation];
        delete votesCountByOperation[operation];
        delete allOperationsIndicies[operation];
    }

    // PUBLIC METHODS

    /**
    * @dev Allows beneficiarys to change their mind by cacnelling votesMaskByOperation operations
    * @param operation defines which operation to delete
    */
    function cancelPending(bytes32 operation) public onlyAnybeneficiary {
        uint beneficiaryIndex = beneficiarysIndices[msg.sender] - 1;
        require((votesMaskByOperation[operation] & (2 ** beneficiaryIndex)) != 0, "cancelPending: operation not found for this user");
        votesMaskByOperation[operation] &= ~(2 ** beneficiaryIndex);
        uint operationVotesCount = votesCountByOperation[operation] - 1;
        votesCountByOperation[operation] = operationVotesCount;
        emit OperationDownvoted(operation, operationVotesCount, beneficiarys.length, msg.sender);
        if (operationVotesCount == 0) {
            deleteOperation(operation);
            emit OperationCancelled(operation, msg.sender);
        }
    }

    /**
    * @dev Allows beneficiarys to change beneficiaryship
    * @param newbeneficiarys defines array of addresses of new beneficiarys
    */
    function transferbeneficiaryship(address[] newbeneficiarys) public {
        transferbeneficiaryshipWithHowMany(newbeneficiarys, newbeneficiarys.length);
    }

    /**
    * @dev Allows beneficiarys to change beneficiaryship
    * @param newbeneficiarys defines array of addresses of new beneficiarys
    * @param newHowManybeneficiarysDecide defines how many beneficiarys can decide
    */
    function transferbeneficiaryshipWithHowMany(address[] newbeneficiarys, uint256 newHowManybeneficiarysDecide) public onlyManybeneficiarys {
        require(newbeneficiarys.length > 0, "transferbeneficiaryshipWithHowMany: beneficiarys array is empty");
        require(newbeneficiarys.length <= 256, "transferbeneficiaryshipWithHowMany: beneficiarys count is greater then 256");
        require(newHowManybeneficiarysDecide > 0, "transferbeneficiaryshipWithHowMany: newHowManybeneficiarysDecide equal to 0");
        require(newHowManybeneficiarysDecide <= newbeneficiarys.length, "transferbeneficiaryshipWithHowMany: newHowManybeneficiarysDecide exceeds the number of beneficiarys");

        // Reset beneficiarys reverse lookup table
        for (uint j = 0; j < beneficiarys.length; j++) {
            delete beneficiarysIndices[beneficiarys[j]];
        }
        for (uint i = 0; i < newbeneficiarys.length; i++) {
            require(newbeneficiarys[i] != address(0), "transferbeneficiaryshipWithHowMany: beneficiarys array contains zero");
            require(beneficiarysIndices[newbeneficiarys[i]] == 0, "transferbeneficiaryshipWithHowMany: beneficiarys array contains duplicates");
            beneficiarysIndices[newbeneficiarys[i]] = i + 1;
        }
        
        emit beneficiaryshipTransferred(beneficiarys, howManybeneficiarysDecide, newbeneficiarys, newHowManybeneficiarysDecide);
        beneficiarys = newbeneficiarys;
        howManybeneficiarysDecide = newHowManybeneficiarysDecide;
        allOperations.length = 0;
        beneficiarysGeneration++;
    }

}