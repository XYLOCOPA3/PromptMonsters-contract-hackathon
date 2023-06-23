import { PromptMonstersExtension } from "../../../typechain-types";
import { ethers, upgrades } from "hardhat";

export async function deployPromptMonstersExtension() {
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

  const promptMonstersExtension = PromptMonstersExtension.attach(
    promptMonstersExtensionProxy.address,
  );

  const args: PromptMonstersExtensionArgs = {
    promptMonstersExtension,
  };
  return args;
}

export type PromptMonstersExtensionArgs = {
  promptMonstersExtension: PromptMonstersExtension;
};
