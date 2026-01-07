import { Transaction } from "@mysten/sui/transactions";

export const transferHero = (heroId: string, to: string) => {
  const tx = new Transaction();

  // TODO: Transfer hero to another address
  tx.transferObjects(
    [tx.object(heroId)], // Transfer edilecek objeler dizisi (Köşeli parantez şart)
    to                   // Alıcının adresi
  );

  return tx;
};