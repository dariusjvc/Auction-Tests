require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.4"
      }
    ]
  },
  networks: {
    miRed: {
      url: `https://sepolia.infura.io/v3/1f8bf23bc72e4c7e8eb77723420668da`,
      accounts: [
        `0xaf9d39a858cd7835fda0a8cadb6e127a174e20ee04ba0f551fb41edad6db19df`,
        `0x0da48a543706621e40e97a2f12bf967ea543b0f5a925a8b52345c9215698ba77`,
        `0x4cef5ad9a3e79354173d08ea60353849ee504db083243843a85b290ead78961f`
      ]
    }
  },
  mocha: {
    timeout: 120000
  }
};
