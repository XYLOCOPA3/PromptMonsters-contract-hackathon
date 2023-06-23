import { PROMPT_MONSTERS_IMAGE_PROXY_ADDRESS } from "../const";
import { ethers, upgrades } from "hardhat";

async function main() {
  console.log("---------------------------------------------");
  console.log("--- Start PromptMonstersImage Upgrade -------");
  console.log("---------------------------------------------");
  console.log("");

  console.log("--- Upgrade ---------------------------------");

  console.log("Upgrading...");

  const [deployer] = await ethers.getSigners();
  console.log("Upgrading contracts with account: ", deployer.address);
  console.log(
    "Upgrade PromptMonstersImageProxy address: ",
    PROMPT_MONSTERS_IMAGE_PROXY_ADDRESS,
  );

  const PromptMonstersImage = await ethers.getContractFactory(
    "PromptMonstersImage",
  );
  const promptMonstersImageProxy = await upgrades.upgradeProxy(
    PROMPT_MONSTERS_IMAGE_PROXY_ADDRESS,
    PromptMonstersImage,
  );
  await promptMonstersImageProxy.deployed();
  console.log(
    "Upgraded PromptMonstersImage implementation:",
    await upgrades.erc1967.getImplementationAddress(
      PROMPT_MONSTERS_IMAGE_PROXY_ADDRESS,
    ),
  );

  console.log("Completed upgrade");

  console.log("");
  console.log("---------------------------------------------");
  console.log("--- End PromptMonstersImage Upgrade ---------");
  console.log("---------------------------------------------");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
