import { deploy } from "./Deployment/Deployment";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("PromptMonsters", function () {
  async function init() {
    const { promptMonsters } = await loadFixture(deploy);

    const [deployer] = await ethers.getSigners();

    return {
      promptMonsters,
      deployer,
    };
  }

  describe("Deployment", function () {
    it("deploy", async function () {
      const { promptMonsters } = await loadFixture(init);
      expect(promptMonsters.address).to.not.equal(
        ethers.constants.AddressZero,
        "zero address",
      );
    });
  });
});
