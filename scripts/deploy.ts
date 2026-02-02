import { network } from "hardhat";

async function main() {
  const { viem } = await network.connect({
    network: "local999",
    chainType: "l1",
  });

  const [deployer] = await viem.getWalletClients();

  console.log("Deploying with:", deployer.account.address);

  const token = await viem.deployContract("ContractDevToken");
  console.log("ContractDevToken deployed to:", token.address);

  const treasury = await viem.deployContract("ContractDevTreasury");
  console.log("ContractDevTreasury deployed to:", treasury.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
