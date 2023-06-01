import {
  PROMPT_MONSTERS_EXTERNAL_LINK,
  MOCK_ERC20_ADDRESS,
  PROMPT_MONSTERS_WALLET,
  MINT_PRICE,
} from "../const";
import { ethers, upgrades } from "hardhat";

async function main() {
  console.log("---------------------------------------------");
  console.log("--- Start PromptMonsters Deploy -------------");
  console.log("---------------------------------------------");
  console.log("");

  console.log("--- Deploy ----------------------------------");

  console.log("Deploying...");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account: ", deployer.address);

  const PromptMonsters = await ethers.getContractFactory("PromptMonsters");
  const promptMonstersProxy = await upgrades.deployProxy(
    PromptMonsters,
    [
      PROMPT_MONSTERS_EXTERNAL_LINK,
      MOCK_ERC20_ADDRESS,
      MINT_PRICE,
      PROMPT_MONSTERS_WALLET,
    ],
    {
      kind: "uups",
      initializer: "initialize",
    },
  );
  await promptMonstersProxy.deployed();
  console.log(
    "Deployed PromptMonstersProxy address: ",
    promptMonstersProxy.address,
  );
  console.log(
    "PromptMonsters implementation deployed to:",
    await upgrades.erc1967.getImplementationAddress(
      promptMonstersProxy.address,
    ),
  );

  console.log("Completed deployment");

  console.log("");
  console.log("---------------------------------------------");
  console.log("--- End PromptMonsters Deploy ---------------");
  console.log("---------------------------------------------");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
