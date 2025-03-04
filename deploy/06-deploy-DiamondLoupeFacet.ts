import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployDiamondLoupeFacet: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("DiamondLoupeFacet", {
    from: deployer,
    log: true,
    autoMine: true,
  });
};

export default deployDiamondLoupeFacet;
deployDiamondLoupeFacet.tags = ["DiamondLoupeFacet"];
