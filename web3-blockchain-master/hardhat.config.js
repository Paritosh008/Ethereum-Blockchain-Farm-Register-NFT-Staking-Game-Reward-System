require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
// require("@nomiclabs/hardhat-ethers");
// require("@nomiclabs/hardhat-etherscan")
/** @type import('hardhat/config').HardhatUserConfig */

const API_URL = process.env.API_URL;
const key = process.env.PRIVATE_KEY;
const apiKey = process.env.API_KEY;
module.exports = {
  solidity: {
    compilers: [
      {
      version: '0.8.20'
      }
    ],
  },
  defaultNetwork:'polygon_mumbai',
  networks:{
    hardhat:{},
    polygon_mumbai:{
      url: API_URL,
      accounts:[`0x${key}`]
    }
  },
  etherscan:{
    apiKey:apiKey
  }
};
