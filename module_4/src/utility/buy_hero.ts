import { Transaction } from "@mysten/sui/transactions";

export const buyHero = (packageId: string, listHeroId: string, priceInSui: string) => {
  const tx = new Transaction();
  
  // TODO: Convert SUI to MIST (1 SUI = 1,000,000,000 MIST)
  // const priceInMist = ?
  const priceInMist = Number(priceInSui) * 1_000_000_000;

  
  // TODO: Split coin for exact payment
  // Use tx.splitCoins(tx.gas, [priceInMist]) to create a payment coin
  // const [paymentCoin] = ?
  const [paymentCoin] = tx.splitCoins(tx.gas, [priceInMist]);

  tx.moveCall({
    target:`${packageId}::hero::buy_hero`,
    arguments: [
      tx.object(listHeroId),
      paymentCoin
    ]
  });
  // TODO: Add moveCall to buy a hero
  // Function: `${packageId}::hero::buy_hero`
  // Arguments: listHeroId (object), paymentCoin (coin)
  // Hints:
  // - Use tx.object() for the ListHero object
  // - Use the paymentCoin from splitCoins for payment
  
  return tx;
};
