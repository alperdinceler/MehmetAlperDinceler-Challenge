import { Transaction } from "@mysten/sui/transactions";

export const delist = (
  packageId: string,
  listHeroId: string,
  adminCapId: string,
) => {
  const tx = new Transaction();

  // TODO: Add moveCall to delist a hero (Admin only)
  tx.moveCall({
    target: `${packageId}::marketplace::delist`,
    arguments: [
      tx.object(adminCapId), // Admin yetki objesi (Admin Capability)
      tx.object(listHeroId), // Listeden kaldırılacak kahraman objesi
    ],
  });

  return tx;
};
