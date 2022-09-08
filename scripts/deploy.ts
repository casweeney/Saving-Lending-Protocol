import { ethers } from "hardhat";

const main = async () => {
  const SavingLending = await ethers.getContractFactory("SavingLending");
  const savingLending = await SavingLending.deploy();

  await savingLending.deployed();

  console.log("SavingLending Contract deployed to:", savingLending.address);
  /// Contract deployed on goerli at: 0x578265AE9AADafBcDd62788AB430Df831374bCd8
  /// Contract deployed on rinkeby at: 0x65608D40b2bE2B9374556238eda72a6693Ae8664
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});