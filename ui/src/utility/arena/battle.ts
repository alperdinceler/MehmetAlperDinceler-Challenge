import { Transaction } from "@mysten/sui/transactions";

export const battle = (packageId: string, heroId: string, arenaId: string) => {
  const tx = new Transaction();

  // TODO: Add moveCall to start a battle
  tx.moveCall({
    target: `${packageId}::arena::battle`,
    arguments: [
      tx.object(heroId),  // Senin kahramanın (Object)
      tx.object(arenaId), // Meydan okunan Arena (Object)
    ],
  });

  return tx;
};