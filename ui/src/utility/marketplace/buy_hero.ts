import { Transaction } from "@mysten/sui/transactions";

export const buyHero = (packageId: string, listHeroId: string, priceInSui: string) => {
  const tx = new Transaction();

  // 1. ADIM: Fiyat Dönüşümü (SUI -> MIST)
  // Güvenli matematiksel işlem için Number ve BigInt kullanımı
  const priceInMist = BigInt(Math.floor(Number(priceInSui) * 1_000_000_000));

  // 2. ADIM: Ödeme Coin'ini Ayırma (Split Coin)
  // Cüzdanın ana bakiyesinden (tx.gas), tam olarak ürün fiyatı kadar (priceInMist) yeni bir coin oluşturuyoruz.
  const [paymentCoin] = tx.splitCoins(tx.gas, [priceInMist]);

  // 3. ADIM: Satın Alma Çağrısı (Move Call)
  tx.moveCall({
    target: `${packageId}::marketplace::buy_hero`,
    arguments: [
      tx.object(listHeroId), // Satın alınacak listeleme objesi
      paymentCoin,           // Az önce oluşturduğumuz, içinde tam para olan coin
    ],
  });

  return tx;
};