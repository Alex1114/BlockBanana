const { ethers } = require("hardhat");

const NFT = artifacts.require("BlockBanana");

module.exports = async ({
  getNamedAccounts,
  deployments,
  getChainId,
  getUnnamedAccounts,
}) => {
  const {deploy, all} = deployments;
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  console.log("");
  console.log("Deployer: ", deployer.address);

  nft = await deploy('BlockBanana', {
    contract: "BlockBanana",
    from: deployer.address,
    args: [
    ],
  });

  console.log("BlockBanana address: ", nft.address);
};

module.exports.tags = ['BlockBanana'];