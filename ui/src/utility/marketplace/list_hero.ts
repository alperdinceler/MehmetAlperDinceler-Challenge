import { Transaction } from "@mysten/sui/transactions";

export const listHero = (
  packageId: string,
  heroId: string,
  priceInSui: string,
) => {
  const tx = new Transaction();

  // 1. ADIM: Fiyat Dönüşümü (SUI -> MIST)
  // Girdi string olduğu için önce Number() ile sayıya, sonra işlem yapıp BigInt'e çeviriyoruz.
  const priceInMist = BigInt(Math.floor(Number(priceInSui) * 1_000_000_000));

  // 2. ADIM: Listeleme Çağrısı (Move Call)
  tx.moveCall({
    target: `${packageId}::marketplace::list_hero`,
    arguments: [
      tx.object(heroId),        // Satışa çıkacak olan Hero (Obje)
      tx.pure.u64(priceInMist), // İstenen fiyat (Sayısal değer)
    ],
  });

  return tx;
};