async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying from:", deployer.address);

  const Item = await ethers.getContractFactory("ChamematItem");
  const item = await Item.deploy();
  await item.waitForDeployment();
  console.log("ChamematItem:", await item.getAddress());

  const Crafting = await ethers.getContractFactory("Crafting");
  const crafting = await Crafting.deploy(await item.getAddress());
  await crafting.waitForDeployment();
  console.log("Crafting:", await crafting.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
