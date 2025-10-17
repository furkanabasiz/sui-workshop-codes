import { Transaction } from "@mysten/sui/transactions";

export const listHero = (packageId: string, heroId: string, priceInSui: string) => {
  const tx = new Transaction();
  
  // TODO: Convert SUI to MIST (1 SUI = 1,000,000,000 MIST)
  // const priceInMist = ?
  const priceInMist = Number(priceInSui) * 1_000_000_000;
  
  // TODO: Add moveCall to list a hero for sale
  // Function: `${packageId}::hero::list_hero`
  // Arguments: heroId (object), priceInMist (u64)
  // Hints:
  // - Use tx.object() for the hero object
  // - Use tx.pure.u64() for the price in MIST
  // - Remember: 1 SUI = 1_000_000_000 MIST
  tx.moveCall({
    target:`${packageId}::hero::list_hero`,
    arguments:[
      tx.object(heroId),
      tx.pure.u64(priceInMist)
    ]
  });
  
  return tx;
};
