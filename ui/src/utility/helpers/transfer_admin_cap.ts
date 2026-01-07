import { Transaction } from "@mysten/sui/transactions";

export const transferAdminCap = (adminCapId: string, to: string) => {
  const tx = new Transaction();

  // TODO: Transfer admin capability to another address
  tx.transferObjects(
    [tx.object(adminCapId)], // Transfer edilecek objelerin listesi (dizi içinde olmalı)
    to                       // Yeni sahibin cüzdan adresi
  );

  return tx;
};