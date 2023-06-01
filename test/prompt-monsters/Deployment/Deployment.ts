import { deployPromptMonsters } from "./PromptMonsters";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

export async function deploy() {
  const { promptMonsters } = await loadFixture(deployPromptMonsters);

  return {
    promptMonsters,
  };
}
