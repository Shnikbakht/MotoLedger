import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";

const initializeDiamond: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { execute, get } = hre.deployments;

  // Call the `init` function in DiamondInit
  await execute("DiamondInit", { from: deployer }, "init");

  console.log("✅ Diamond Proxy initialized!");
};

export default initializeDiamond;
initializeDiamond.tags = ["InitializeDiamond"];
initializeDiamond.dependencies = ["Diamond", "DiamondInit"];
