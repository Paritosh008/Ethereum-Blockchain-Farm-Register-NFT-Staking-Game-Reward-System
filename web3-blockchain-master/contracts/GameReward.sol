//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GameReward {

        address public admin;
        address manager;
        IERC20 public  immutable rewardToken;
        uint256 public rewardRate = 100;
        mapping(string userId => uint256 points) public userPoints;
        mapping(string userId => uint256 points) public boughtPoints;

        constructor( address _manager, address _rewardToken){
                admin = msg.sender;
                manager = _manager;
                rewardToken = IERC20(_rewardToken);
             
        }

        event pointsPurchased(string userId, uint256 points); 

        modifier adminOnly() {
                require(msg.sender == admin, "Only admin is allowed to perform this action");
                _;
        }

        modifier managerOnly() {
                require(msg.sender == manager, "Only manager is allowed to perform this action");
                _;
        }

        function balance () external adminOnly view returns (uint256) {
                return rewardToken.balanceOf(address(this));
        }
        
        function depositToken(uint256 amount) external adminOnly {
                require(rewardToken.allowance(msg.sender, address(this)) >= amount,"Don't have permission to deposit this ammount");
                rewardToken.transferFrom(msg.sender, address(this), amount);
        }

        function withdrawToken(uint256 amount) external  adminOnly{
                require(rewardToken.balanceOf(address(this)) >= amount, "amount greater than available balance");
                rewardToken.transfer(msg.sender, amount);
        }

        function updateRewardRate(uint _rewardRate) external adminOnly returns(uint256){
                rewardRate = _rewardRate;
                return rewardRate;
        }

        function calculateRewardToken(uint256 points) internal view returns (uint256) {
                // uint decimals = rewardToken.decimals();
                //replace 18 with decimals in the given token;
                uint256 token = (points *10**18)/rewardRate;
                return token;
        }

        function claimReward(string memory userId, uint256 points, address walletAddress) external managerOnly {
                require(userPoints[userId] >= points, "Insufficent reward points");
                uint256 token = calculateRewardToken(points);
                require(rewardToken.balanceOf(address(this))>=token, "Insufficient token balance");
                userPoints[userId] -= points;
                rewardToken.transfer(walletAddress, token);
        }

        function updateUserPoints (string memory userId, uint256 points) external managerOnly returns(uint256){
                userPoints[userId] = points;
                return userPoints[userId];
        }

        function calculatePoints(uint tokenAmount) internal view returns(uint256){
                uint256 points = (tokenAmount * rewardRate)/10**18;
                return points;
        }

        function buyPoints(uint tokenAmount, string memory userId) external returns(uint256){ 

                require(rewardToken.balanceOf(msg.sender) >= tokenAmount, "Insufficient user balance");
                require(rewardToken.allowance(msg.sender, address(this)) >= tokenAmount,"Not approved to transfer given amount of token");
                rewardToken.transferFrom(msg.sender, address(this), tokenAmount);
                uint256 points = calculatePoints(tokenAmount);
                emit pointsPurchased(userId, points);
                boughtPoints[userId] = points;
                return points;
        }




}