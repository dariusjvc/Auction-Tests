require("@nomiclabs/hardhat-waffle");
// hardhat.config.js

require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config();

process.env.NODE_TLS_REJECT_UNAUTHORIZED='0'

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.7.3"
      },
      {
        version: "0.8.0"
      },
      {
        version: "0.8.1"
      },
      {
        version: "0.8.2"
      },
      {
        version: "0.8.9"
      }
    ]
  },
  networks: {
    miRed: {
          url: `https://sepolia.infura.io/v3/1f8bf23bc72e4c7e8eb77723420668da`,
          accounts: [`0xaf9d39a858cd7835fda0a8cadb6e127a174e20ee04ba0f551fb41edad6db19df`]
        }
  }
};
