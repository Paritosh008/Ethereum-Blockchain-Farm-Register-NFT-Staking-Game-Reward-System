// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {ethers}= require("hardhat");

async function main() {
  
  // const mainMarketplace = await ethers.getContractFactory("Marketplace");

  // const deployedMainMarketplace = await mainMarketplace.deploy('0x2C280905F711722894d9748773E80F31fF2b8Be2', "0xDbf9d2D1D658F6A24271CCABa8334B7AffB32C07");
  // const mainAddress = await deployedMainMarketplace.getAddress();
  
  // console.log("deployedMainMarketplace ==>", mainAddress);


  // // const vxtMarketplace = await ethers.getContractFactory("VXTMarketplace");

  // const deployedVxtMarketplace = await ethers.getContractAt("VXTMarketplace",mainAddress);
  // const vxtAddress = await deployedVxtMarketplace.getAddress();
  
  // console.log("deployedVxtMarketplace ==>", vxtAddress);

  // try{
  //   const factoryContract = await ethers.getContractFactory("FactoryERC1155");
  //   const deployedFactoryContract = await factoryContract.deploy();
  //   console.log("deployedFactoryContract ==>", await deployedFactoryContract.getAddress())
  // }catch(err){
  //   console.log("error in deploying factoryContract ", err);
  // };

    // const stakingFarm = await ethers.getContractFactory("RewardFarm");
  // const deployedStakingFarm = await stakingFarm.deploy("0x4528399d1ab6f90fa208c516bb12124031e68694","0x4528399d1ab6f90fa208c516bb12124031e68694","0xB375B41e238222a390940178D6027959f604a266");
  // console.log("Staking contract address =>", deployedStakingFarm.address);


  // const Dapptoken = await ethers.getContractFactory("DappToken");
  // const token = await Dapptoken.deploy();
  // console.log("Dapp token contract address =>", token.address);

    const gameReward = await ethers.getContractFactory("GameReward");
  const deployedGameReward = await gameReward.deploy("0x2C280905F711722894d9748773E80F31fF2b8Be2", "0xDbf9d2D1D658F6A24271CCABa8334B7AffB32C07");
  const gameRewardAddress = await deployedGameReward.getAddress();
  console.log("Game reward contract: ",gameRewardAddress);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
