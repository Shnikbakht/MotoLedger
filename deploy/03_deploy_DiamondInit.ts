import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployDiamondInit: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("DiamondInit", {
    from: deployer,
    log: true,
    autoMine: true,
  });
};

export default deployDiamondInit;
deployDiamondInit.tags = ["DiamondInit"];
