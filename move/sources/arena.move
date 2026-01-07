module challenge::arena;

use challenge::hero::Hero;
use sui::event;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {

    // TODO: Create an arena object
        // Hints:
        // Use object::new(ctx) for unique ID
    let arena = Arena {
        id: sui::object::new(ctx),
        // Set warrior field to the hero parameter
        warrior: hero,
        // Set owner to ctx.sender()
        owner: tx_context::sender(ctx),
    };
    // TODO: Emit ArenaCreated event with arena ID and timestamp (Don't forget to use ctx.epoch_timestamp_ms(), object::id(&arena))
    event::emit(ArenaCreated {
    arena_id: object::id(&arena),
    timestamp: tx_context::epoch_timestamp_ms(ctx)
});
    // TODO: Use transfer::share_object() to make it publicly tradeable
    transfer::share_object(arena);

}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    
    // 1. Arena objesini parçala (Destructure).
    // Bu işlem 'arena' objesini tüketir, yani fonksiyon sonunda bu obje artık var olmayacak.
    let Arena { id, warrior, owner } = arena;

    // Gönderen (Sender) adresini al
    let sender = tx_context::sender(ctx);
    let hero_id = object::id(&hero);
    let warrior_id = object::id(&warrior);
    // 2. Güçleri Karşılaştır (hero_power() fonksiyonunun veya alanının var olduğunu varsayıyoruz)
    // Not: prompt'ta hero.hero_power() dendiği için metod çağrısı yapıyoruz, 
    // ancak doğrudan hero.power şeklinde de olabilir.
    if (hero.hero_power() > warrior.hero_power()) {
        
        // --- HERO KAZANDI ---
        
        // Kazanan (Sender) iki kahramanı da alır
        transfer::public_transfer(hero, sender);
        transfer::public_transfer(warrior, sender);

        // Event Fırlat
        event::emit(ArenaCompleted {
            winner_hero_id: hero_id,
            loser_hero_id: warrior_id,
            timestamp: ctx.epoch_timestamp_ms(),
            // Diğer gerekli alanlar...
        });

    } else {
        
        // --- WARRIOR (SAVUNAN) KAZANDI ---
        
        // Arena sahibi (owner) iki kahramanı da alır
        transfer::public_transfer(hero, owner);
        transfer::public_transfer(warrior, owner);

        // Event Fırlat
        event::emit(ArenaCompleted {
            winner_hero_id: warrior_id,
            loser_hero_id: hero_id,
            timestamp: ctx.epoch_timestamp_ms(),
            // Diğer gerekli alanlar...
        });
    };

    // 3. Arena ID'sini sil (Bu işlem zincir üzerinde objeyi kalıcı olarak siler)
    object::delete(id);
}

