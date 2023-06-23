import {
  PROMPT_MONSTERS_IMAGE_PROXY_ADDRESS,
  PROMPT_MONSTERS_PROXY_ADDRESS,
} from "../const";
import { ethers } from "hardhat";

async function main() {
  console.log("---------------------------------------------");
  console.log("--- Start PromptMonstersImage Post Deploy ---");
  console.log("---------------------------------------------");
  console.log("");

  console.log("--- Post Deploy -----------------------------");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account: ", deployer.address);

  const PromptMonstersImage = await ethers.getContractFactory(
    "PromptMonstersImage",
  );
  const promptMonstersImage = PromptMonstersImage.attach(
    PROMPT_MONSTERS_IMAGE_PROXY_ADDRESS,
  );

  console.log("Set PromptMonsters address -------------");
  console.log(`Before: ${await promptMonstersImage.getPromptMonsters()}`);
  await (
    await promptMonstersImage.setPromptMonsters(PROMPT_MONSTERS_PROXY_ADDRESS)
  ).wait();
  console.log(`After : ${await promptMonstersImage.getPromptMonsters()}`);
  console.log("DONE!!!");

  console.log("");
  console.log("---------------------------------------------");
  console.log("--- End PromptMonstersImage Post Deploy -----");
  console.log("---------------------------------------------");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
