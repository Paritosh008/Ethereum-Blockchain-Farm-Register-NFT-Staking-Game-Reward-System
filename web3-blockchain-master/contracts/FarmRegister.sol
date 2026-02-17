// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RewardFarm.sol";

contract VoeuxFarmRegistry {

    address private adminAccount;
    uint private totalFarmsRegistered = 0;
    mapping(uint256 => Farm) private farms;
    mapping(uint256 => mapping(address => uint256)) private rewards;
    mapping(address => bool) private allowedTokens; 

    enum Status { Inactive, Active, Completed, Paused, Skipped, Terminate }

    enum TokenStatus { Supported, Not_Supported }

    enum LockInPeriod { Daily, Weekly, Monthly, Quarterly, HalfYearly, Yearly }

    struct Phase {
        uint256 priority;
        string name;
        string detail;
        Status status;
    }

    struct Farm {
        string name;
        string description;
        uint256 investmentRequired;
        address tokenAddressForInvestment;
        Status status;
        uint256 maxPhase;
        mapping(uint256 => Phase) phases;
        address manager;
        uint256 totalInvested;
        address farmContractAddress;
        uint256 apy;
    }

    constructor() {
        adminAccount = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAccount, "Only admin can call this function");
        _;
    }

    modifier onlyFarmToken(uint256 farmId, address tokenAddress) {
        require(bytes(farms[farmId].name).length != 0, "Farm does not exist.");
        require(farms[farmId].tokenAddressForInvestment == tokenAddress, "Farm doesn't accept the token");
        _;
    }

    modifier onlyManager(uint256 farmId) {
        require(bytes(farms[farmId].name).length != 0, "Farm does not exist.");
        require(msg.sender == farms[farmId].manager, "Only farm manager can call this function");
        _;
    }

    // events
    event NewFarmRegisteration(string farmName, uint256 farmId, uint256 investmentRequirement, address tokenAddress, address managerAddress, address farmAddress);
    event NewStake(address sender, uint256 farmId, address tokenAddress, uint256 tokenCount);
    event NewUnstake(address sender, uint256 farmId, address tokenAddress, uint256 tokenCount);

    // get admin address
    function getAdminAddress() external view returns (address){
        return adminAccount;
    }

    // get total Farm Registered Count
    function getCountOfTotalFarmRegistered() external view returns (uint256){
        return totalFarmsRegistered;
    }

    // check for token allowed or not
    function checkTokenAllowedStatus(address tokenAddress) external view returns (TokenStatus){
        if(allowedTokens[tokenAddress] == true){
            return TokenStatus.Supported;
        }
        return TokenStatus.Not_Supported;
    }

    // register farm by admin of the farm
    function registerFarm(
        string memory _name,
        string memory _description,
        uint256 _investmentRequired,
        address _tokenAddress,
        Phase[] memory _phases,
        address _manager,
        uint256 _apy
    ) external onlyAdmin returns (uint256) {
        // check the passed adderss for token is allowed or not
        uint256 farmId = totalFarmsRegistered;
        farms[farmId].name = _name;
        farms[farmId].description = _description;
        farms[farmId].investmentRequired = _investmentRequired;
        farms[farmId].tokenAddressForInvestment = _tokenAddress;
        farms[farmId].status = Status.Inactive;
        farms[farmId].maxPhase = _phases.length;
        farms[farmId].manager = _manager;
        farms[farmId].apy = _apy;
        farms[farmId].totalInvested = 0;
        for (uint256 i = 0; i < _phases.length; i++) {
            farms[farmId].phases[i] = _phases[i];
        }
        totalFarmsRegistered += 1;

        // Deploy the farm contract
        RewardFarm farmContract = new RewardFarm(
            _tokenAddress,
            _tokenAddress,
            _manager
        );
        // Store the farm contract address in the Farm object
        farms[farmId].farmContractAddress = address(farmContract);
        emit NewFarmRegisteration(farms[farmId].name, farmId, farms[farmId].investmentRequired, farms[farmId].tokenAddressForInvestment, farms[farmId].manager, farms[farmId].farmContractAddress);
        return farmId;
    }

    // get the farm details using the farm id
    function getFarmBasicDetails(uint256 farmId) external view returns (string memory name, string memory description, uint256 investmentRequired, address investmentTokenInvestment) {
        require(bytes(farms[farmId].name).length != 0, "Farm does not exist.");
        return (farms[farmId].name, farms[farmId].description, farms[farmId].investmentRequired, farms[farmId].tokenAddressForInvestment);
    }

    // get advance details of a farm using farmId
    function getFarmAdvanceDetails(uint256 farmId) external view returns (Status status, uint256 maxPhase, address manager, uint256 totalInvestment, uint256 apy, address farmAddress) {
        require(bytes(farms[farmId].name).length != 0, "Farm does not exist.");
        return (farms[farmId].status, farms[farmId].maxPhase, farms[farmId].manager, farms[farmId].totalInvested, farms[farmId].apy, farms[farmId].farmContractAddress);
    }

    // get phase detail of a farm using phaseId and farmId
    function getFarmPhaseDetails(uint256 farmId, uint256 phaseId) external view returns (Phase memory) {
        require(bytes(farms[farmId].name).length != 0, "Farm does not exist.");
        return farms[farmId].phases[phaseId];
    }

    // updation of the farm status by the manager of the farm
    function updateFarmStatus(
        uint256 farmId,
        Status status
    ) external onlyManager(farmId) returns (Status){
        require(bytes(farms[farmId].name).length != 0, "Farm does not exist.");
        farms[farmId].status = status;
        return status;
    }

    // upfation of the fam by the manager of the farm = [_description, _investmentRequired, _phases, _apy]
    function updateFarm(
        uint256 farmId,
        string memory _description,
        uint256 _investmentRequired,
        Phase[] memory _phases,
        uint256 _apy
    ) external onlyManager(farmId) returns (string memory name, string memory description, uint256 investmentRequired, address investmentTokenInvestment){
        farms[farmId].description = _description;
        farms[farmId].investmentRequired = _investmentRequired;
        farms[farmId].apy = _apy;
        farms[farmId].maxPhase = _phases.length;
        for (uint256 i = 0; i < _phases.length; i++) {
            farms[farmId].phases[i] = _phases[i];
        }
        return (farms[farmId].name, farms[farmId].description, farms[farmId].investmentRequired, farms[farmId].tokenAddressForInvestment);
    }

    function updateFarmPhaseStatus(
        uint256 farmId,
        uint256 phaseId,
        Status status
    ) external onlyManager(farmId) returns (Phase memory){
        require(farms[farmId].maxPhase >= phaseId, "Phase is not available");
        farms[farmId].phases[phaseId].status = status;
        return farms[farmId].phases[phaseId];
    }

    function tokenAllowed(address tokenAddress) external onlyAdmin {
        allowedTokens[tokenAddress] = true;
    }
}