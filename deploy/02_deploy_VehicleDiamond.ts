import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

const deployDiamond: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, get } = hre.deployments;

  // Deploy Diamond Proxy
  const diamond = await deploy("VehicleDiamond", {
    from: deployer,
    args: [deployer, (await get("DiamondCutFacet")).address], // DiamondCutFacet is required
    log: true,
    autoMine: true,
  });

  console.log("✅ Diamond Proxy deployed at:", diamond.address);
};

export default deployDiamond;
deployDiamond.tags = ["Diamond"];
deployDiamond.dependencies = ["DiamondCutFacet"]; // Ensures DiamondCutFacet deploys first
