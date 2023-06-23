import { PROMPT_MONSTERS_EXTENSION_PROXY_ADDRESS } from "../const";
import { ethers, upgrades } from "hardhat";

async function main() {
  console.log("---------------------------------------------");
  console.log("--- Start PromptMonstersExtension Upgrade ---");
  console.log("---------------------------------------------");
  console.log("");

  const addr = PROMPT_MONSTERS_EXTENSION_PROXY_ADDRESS;

  console.log("--- Upgrade ---------------------------------");

  console.log("Upgrading...");

  const [deployer] = await ethers.getSigners();
  console.log("Upgrading contracts with account: ", deployer.address);
  console.log("Upgrade PromptMonstersExtensionProxy address: ", addr);

  const PromptMonstersExtension = await ethers.getContractFactory(
    "PromptMonstersExtension",
  );
  const promptMonstersExtensionProxy = await upgrades.upgradeProxy(
    addr,
    PromptMonstersExtension,
  );
  await promptMonstersExtensionProxy.deployed();
  console.log(
    "Upgraded PromptMonstersExtension implementation:",
    await upgrades.erc1967.getImplementationAddress(addr),
  );

  console.log("Completed upgrade");

  console.log("");
  console.log("---------------------------------------------");
  console.log("--- End PromptMonstersExtension Upgrade -----");
  console.log("---------------------------------------------");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
