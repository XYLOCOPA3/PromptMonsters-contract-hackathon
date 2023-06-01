import { deployPromptMonstersImage } from "./utils/DeployPromptMonstersImage";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("PromptMonstersImage", function () {
  async function init() {
    const { promptMonstersImage } = await loadFixture(
      deployPromptMonstersImage,
    );

    return {
      promptMonstersImage,
    };
  }

  describe("Deployment", function () {
    it("deploy", async function () {
      const { promptMonstersImage } = await loadFixture(init);
      expect(promptMonstersImage.address).to.not.equal(
        ethers.constants.AddressZero,
        "zero address",
      );
    });
  });
});
