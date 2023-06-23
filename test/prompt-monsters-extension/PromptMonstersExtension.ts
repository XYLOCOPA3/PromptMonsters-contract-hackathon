import { deployPromptMonstersExtension } from "./utils/DeployPromptMonstersExtension";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("PromptMonstersExtension", function () {
  async function init() {
    const { promptMonstersExtension } = await loadFixture(
      deployPromptMonstersExtension,
    );

    return {
      promptMonstersExtension,
    };
  }

  describe("Deployment", function () {
    it("deploy", async function () {
      const { promptMonstersExtension } = await loadFixture(init);
      expect(promptMonstersExtension.address).to.not.equal(
        ethers.constants.AddressZero,
        "zero address",
      );
    });
  });
});
