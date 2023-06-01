import { PromptMonstersImage } from "../../../typechain-types";
import { ethers, upgrades } from "hardhat";

export async function deployPromptMonstersImage() {
  const initArgs: promptMonstersImageInitArgs = {
    promptMonstersAddress: ethers.constants.AddressZero,
  };

  const PromptMonstersImage = await ethers.getContractFactory(
    "PromptMonstersImage",
  );
  const promptMonstersImageProxy = await upgrades.deployProxy(
    PromptMonstersImage,
    [initArgs.promptMonstersAddress],
    {
      kind: "uups",
      initializer: "initialize",
    },
  );
  await promptMonstersImageProxy.deployed();

  const promptMonstersImage = PromptMonstersImage.attach(
    promptMonstersImageProxy.address,
  );

  const args: PromptMonstersImageArgs = {
    promptMonstersImage,
    initArgs,
  };
  return args;
}

export type PromptMonstersImageArgs = {
  promptMonstersImage: PromptMonstersImage;
  initArgs: promptMonstersImageInitArgs;
};

export type promptMonstersImageInitArgs = {
  promptMonstersAddress: string;
};
