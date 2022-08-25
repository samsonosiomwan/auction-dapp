import { ethers } from "hardhat";

async function main() {
  const AUCTION = await ethers.getContractFactory("Auction");
  const auction = await AUCTION.deploy()
  

  await auction.deployed();

  console.log(`sucessfullDeployed at address ${auction.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

// contract address
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
