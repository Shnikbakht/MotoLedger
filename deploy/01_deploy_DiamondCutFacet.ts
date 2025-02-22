import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployDiamondCutFacet: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("DiamondCutFacet", {
    from: deployer,
    log: true,
    autoMine: true,
  });
};

export default deployDiamondCutFacet;
deployDiamondCutFacet.tags = ["DiamondCutFacet"];
