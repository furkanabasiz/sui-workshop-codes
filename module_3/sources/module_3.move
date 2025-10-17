module module_3::hero; 
    // ========= IMPORTS =========
    use std::string::String;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::event;
    
    // ========= STRUCTS =========
    public struct Hero has key, store {
        id: UID,
        name: String,
        image_url: String,
        power: u64,
    }

    public struct ListHero has key, store {
        // TODO: Add the fields for the ListHero
        // 1. The id of the ListHero
        id: UID,
        // 2. The nft object
        nft: Hero,
        // 3. The price of the Hero
        price: u64,
        // 4. The seller of the Hero
        seller: address
    }

    public struct HeroMetadata has key, store {
        // TODO: Add the fields for the HeroMetadata
        // 1. The id of the HeroMetadata
        id:UID,
        // 2. The timestamp of the HeroMetadata
        timestamp: u64
    }

    // ========= EVENTS =========

    public struct HeroListed has copy, drop {
        // TODO: Add the fields for the HeroListed
        // 1. The id of the HeroListed
        id: ID,
        // 2. The price of the Hero
        price: u64,
        // 3. The seller of the Hero
        seller: address,
        // 4. The timestamp of the HeroListed
        timestamp: u64
    }

    public struct HeroBought has copy, drop {
        // TODO: Add the fields for the HeroBought
        // 1. The id of the HeroBought
        id:ID,
        // 2. The price of the Hero
        price: u64,
        // 3. The buyer of the Hero
        buyer: address,
        // 4. The seller of the Hero
        seller: address,
        // 5. The timestamp of the HeroBought
        timestamp: u64
    }

    // ========= FUNCTIONS =========

    #[allow(lint(self_transfer))]
    public entry fun create_hero(name: String, image_url: String, power: u64,  ctx: &mut TxContext) {
        let hero = Hero {
            id: object::new(ctx),
            name,
            image_url,
            power
        };

        let hero_metadata = HeroMetadata {
            id: object::new(ctx),
            timestamp: tx_context::epoch_timestamp_ms(ctx) 
        };

        transfer::transfer(hero, ctx.sender());

        // TODO: Freeze the HeroMetadata object
        transfer::freeze_object(hero_metadata);
        
    }



    public entry fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {
        // TODO: Define the ListHero object,
        let list_hero = ListHero {
            // TODO: Define the fields for the ListHero object
            // 1. Create the object id for the ListHero object
            id: object::new(ctx),
            // 2. The nft object
            nft: nft,
            // 3. The price of the Hero
            price: price,
            // 4. The seller of the Hero (the sender)
            seller: ctx.sender()
        };

        // TODO: Emit the HeroListed event
        event::emit(HeroListed {
            id: object::id(&list_hero),
            price: price,
            seller: ctx.sender(),
            timestamp: tx_context::epoch_timestamp_ms(ctx)
        });

        // TODO: Share the ListHero object 
        transfer::share_object(list_hero)
        
    }

    public entry fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {
        // TODO: Deconstruct the ListHero object
        let ListHero {id, nft, price, seller} = list_hero;
        // TODO: Assert the price of the Hero is equal to the coin amount
        assert!(price == coin::value(&coin),1);
        // TODO: Transfer the coin to the seller
        transfer::public_transfer(coin, seller);
        // TODO: Transfer the Hero object to the sender
        transfer::public_transfer(nft, ctx.sender());
        // TODO: Emit the HeroBought event
        event::emit(HeroBought{
        id: id.to_inner(),
        price,
        buyer: ctx.sender(),
        seller: seller,
        timestamp: ctx.epoch_timestamp_ms()
    });

    object::delete(id);
}

    public entry fun transfer_hero(hero: Hero, to: address) {
        transfer::public_transfer(hero, to);
    }

    // ========= GETTER FUNCTIONS =========
    
    #[test_only]
    public fun hero_name(hero: &Hero): String {
        hero.name
    }

    #[test_only]
    public fun hero_image_url(hero: &Hero): String {
        hero.image_url
    }

    #[test_only]
    public fun hero_power(hero: &Hero): u64 {
        hero.power
    }

    #[test_only]
    public fun hero_id(hero: &Hero): ID {
        object::id(hero)
    }
