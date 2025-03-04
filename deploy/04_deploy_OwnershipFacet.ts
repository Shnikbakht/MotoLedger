import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployOwnershipFacet: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("OwnershipFacet", {
    from: deployer,
    log: true,
    autoMine: true,
  });
};

export default deployOwnershipFacet;
deployOwnershipFacet.tags = ["OwnershipFacet"];
