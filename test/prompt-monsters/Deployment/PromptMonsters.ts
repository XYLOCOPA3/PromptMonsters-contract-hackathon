import { PromptMonsters } from "../../../typechain-types";
import { BigNumber } from "ethers";
import { ethers, upgrades } from "hardhat";

export async function deployPromptMonsters() {

  const [deployer, user1, promptMonstersWallet] = await ethers.getSigners();

  const promptMonstersArgs: promptMonstersInitArgs = {
    externalLink: "https://prompt-monsters.com/",
    erc20Address: ethers.constants.AddressZero,
    mintPrice: ethers.utils.parseEther("50"),
    promptMonstersWallet: promptMonstersWallet.address,
  };

  const PromptMonsters = await ethers.getContractFactory("PromptMonsters");
  const promptMonstersProxy = await upgrades.deployProxy(
    PromptMonsters,
    [
      promptMonstersArgs.externalLink,
      promptMonstersArgs.erc20Address,
      promptMonstersArgs.mintPrice,
      promptMonstersArgs.promptMonstersWallet,
    ],
    {
      kind: "uups",
      initializer: "initialize",
    },
  );
  await promptMonstersProxy.deployed();

  const promptMonsters = PromptMonsters.attach(promptMonstersProxy.address);

  return { promptMonsters };
}

export type PromptMonstersArgs = {
  contract: PromptMonsters;
  args: promptMonstersInitArgs;
};

export type promptMonstersInitArgs = {
  externalLink: string;
  erc20Address: string;
  mintPrice: BigNumber;
  promptMonstersWallet: string;
};
