import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployFacets: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying facets with deployer:", deployer);

  // Deploy RegulatoryFacet
  const regulatoryFacet = await deploy("RegulatoryFacet", {
    from: deployer,
    log: true,
  });
  console.log("✅ RegulatoryFacet deployed at:", regulatoryFacet.address);

  // Deploy InsuranceFacet
  const insuranceFacet = await deploy("InsuranceFacet", {
    from: deployer,
    log: true,
  });
  console.log("✅ InsuranceFacet deployed at:", insuranceFacet.address);

  // Deploy MintingFacet
  const mintingFacet = await deploy("MintingFacet", {
    from: deployer,
    log: true,
  });
  console.log("✅ MintingFacet deployed at:", mintingFacet.address);
};

export default deployFacets;
deployFacets.tags = ["Facets"];
