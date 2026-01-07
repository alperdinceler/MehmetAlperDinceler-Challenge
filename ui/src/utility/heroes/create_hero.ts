import { Transaction } from "@mysten/sui/transactions";

export const createHero = (
  packageId: string,
  name: string,
  imageUrl: string,
  power: string,
) => {
  const tx = new Transaction();

  // TODO: Add moveCall to create a hero
  tx.moveCall({
    // İPUCU UYGULANDI: Modül adı 'hero' değil 'arena' olarak ayarlandı.
    target: `${packageId}::hero::create_hero`,
    arguments: [
      tx.pure.string(name),       // İsim (String)
      tx.pure.string(imageUrl),   // Resim URL (String)
      tx.pure.u64(BigInt(power)), // Güç (u64) - String'den BigInt'e çevrildi
    ],
  });

  return tx;
};