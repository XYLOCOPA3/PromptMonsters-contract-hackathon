import { ethers, upgrades } from "hardhat";

async function main() {
  console.log("---------------------------------------------");
  console.log("--- Start PromptMonstersExtension Deploy ----");
  console.log("---------------------------------------------");
  console.log("");

  console.log("--- Deploy ----------------------------------");

  console.log("Deploying...");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account: ", deployer.address);

  const PromptMonstersExtension = await ethers.getContractFactory(
    "PromptMonstersExtension",
  );
  const promptMonstersExtensionProxy = await upgrades.deployProxy(
    PromptMonstersExtension,
    [],
    {
      kind: "uups",
      initializer: "initialize",
    },
  );
  await promptMonstersExtensionProxy.deployed();
  console.log(
    "Deployed PromptMonstersExtensionProxy address: ",
    promptMonstersExtensionProxy.address,
  );
  console.log(
    "PromptMonstersExtension implementation deployed to:",
    await upgrades.erc1967.getImplementationAddress(
      promptMonstersExtensionProxy.address,
    ),
  );

  console.log("Completed deployment");

  console.log("");
  console.log("---------------------------------------------");
  console.log("--- End PromptMonstersExtension Deploy ------");
  console.log("---------------------------------------------");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
