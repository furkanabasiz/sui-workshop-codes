#[test_only]
module module_3::module_3_tests {
    use module_3::hero::{Self, Hero, ListHero};
    use sui::test_scenario::{Self as ts, next_tx};
    use sui::coin;
    use sui::sui::SUI;

    // Error codes for assertions
    const EHeroNameMismatch: u64 = 1;
    const EHeroImageUrlMismatch: u64 = 2;
    const EHeroPowerMismatch: u64 = 3;
    const EHeroNotCreated: u64 = 4;
    const EHeroNotTransferred: u64 = 5;
    const EListHeroNotShared: u64 = 6;

    const SENDER: address = @0x1;
    const RECIPIENT: address = @0x2;
    const PRICE: u64 = 1000000000; // 1 SUI in MIST

    #[test]
    fun test_create_hero() {
        let mut scenario = ts::begin(SENDER);

        // Create a hero
        {
            hero::create_hero(
                b"Ali".to_string(),
                b"https://example.com/ali.png".to_string(),
                9000,
                scenario.ctx(),
            );
        };

        // Move to next transaction to access the created hero
        next_tx(&mut scenario, SENDER);

        // Verify hero was created and test getter functions
        assert!(ts::has_most_recent_for_sender<Hero>(&scenario), EHeroNotCreated);
        
        {
            let hero = ts::take_from_sender<Hero>(&scenario);
            // Test getter functions
            assert!(hero.hero_name() == b"Ali".to_string(), EHeroNameMismatch);
            assert!(hero.hero_image_url() == b"https://example.com/ali.png".to_string(), EHeroImageUrlMismatch);
            assert!(hero.hero_power() == 9000, EHeroPowerMismatch);
            ts::return_to_sender(&scenario, hero);
        };

        ts::end(scenario);
    }

    #[test]
    fun test_transfer_hero() {
        let mut scenario = ts::begin(SENDER);

        // Create a hero first
        {
            hero::create_hero(
                b"Serkan".to_string(),
                b"https://example.com/serkan.png".to_string(),
                8500,
                scenario.ctx(),
            );
        };

        next_tx(&mut scenario, SENDER);

        // Transfer the hero to recipient
        {
            let hero = ts::take_from_sender<Hero>(&scenario);
            hero::transfer_hero(hero, RECIPIENT);
        };

        // Move to next transaction as recipient
        next_tx(&mut scenario, RECIPIENT);

        // Verify hero is now owned by recipient
        assert!(ts::has_most_recent_for_address<Hero>(RECIPIENT), EHeroNotTransferred);

        ts::end(scenario);
    }

    #[test]
    fun test_list_hero() {
        let mut scenario = ts::begin(SENDER);

        // Create a hero first
        {
            hero::create_hero(
                b"Mantas".to_string(),
                b"https://example.com/mantas.png".to_string(),
                7500,
                scenario.ctx(),
            );
        };

        next_tx(&mut scenario, SENDER);

        // List the hero for sale
        {
            let hero = ts::take_from_sender<Hero>(&scenario);
            
            hero::list_hero(hero, PRICE, scenario.ctx());
        };

        next_tx(&mut scenario, SENDER);

        // Verify ListHero object was created and shared
        assert!(ts::has_most_recent_shared<ListHero>(), EListHeroNotShared);

        ts::end(scenario);
    }

    #[test]
    fun test_buy_hero() {
        let mut scenario = ts::begin(SENDER);

        // Create and list a hero
        {
            hero::create_hero(
                b"Teo".to_string(),
                b"https://example.com/teo.png".to_string(),
                6000,
                scenario.ctx(),
            );
        };

        next_tx(&mut scenario, SENDER);

        {
            let hero = ts::take_from_sender<Hero>(&scenario);

            hero::list_hero(hero, PRICE, scenario.ctx());
        };

        next_tx(&mut scenario, RECIPIENT);

        // Buy the hero
        {
            let coin = coin::mint_for_testing<SUI>(PRICE, scenario.ctx());
            let list_hero = ts::take_shared<ListHero>(&scenario);
            
            hero::buy_hero(list_hero, coin, scenario.ctx());
        };

        next_tx(&mut scenario, RECIPIENT);

        // Verify buyer received the hero
        assert!(ts::has_most_recent_for_address<Hero>(RECIPIENT), EHeroNotTransferred);
        
        {
            let hero = ts::take_from_address<Hero>(&scenario, RECIPIENT);
            assert!(hero.hero_name() == b"Teo".to_string(), EHeroNameMismatch);
            assert!(hero.hero_power() == 6000, EHeroPowerMismatch);
            ts::return_to_address(RECIPIENT, hero);
        };

        ts::end(scenario);
    }

}