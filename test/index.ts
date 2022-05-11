import { expect } from "chai";
import { ethers } from "hardhat";

describe("Deploy factory", function () {
  it("deploy factory", async function () {
    const addrs = await ethers.getSigners();
    const owner = addrs[0].address;
    const Factory= await ethers.getContractFactory("CapswapV2Factory");
    const factory= await Factory.deploy(owner);
    await factory.deployed();

    console.log("Factory",factory.address);
    console.log("initCodeHash",await factory.initCodeHash());
    expect(await factory.feeToSetter()).to.equal(owner);

  });
});
