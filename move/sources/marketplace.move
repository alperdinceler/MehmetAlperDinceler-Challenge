module challenge::marketplace;

use challenge::hero::Hero;
use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;

// ========= ERRORS =========

const EInvalidPayment: u64 = 1;

// ========= STRUCTS =========

public struct ListHero has key, store {
    id: UID,
    nft: Hero,
    price: u64,
    seller: address,
}

// ========= CAPABILITIES =========

public struct AdminCap has key, store {
    id: UID,
}

// ========= EVENTS =========

public struct HeroListed has copy, drop {
    list_hero_id: ID,
    price: u64,
    seller: address,
    timestamp: u64,
}

public struct HeroBought has copy, drop {
    list_hero_id: ID,
    price: u64,
    buyer: address,
    seller: address,
    timestamp: u64,
}

// ========= FUNCTIONS =========

fun init(ctx: &mut TxContext) {
    // 1. AdminCap (Yönetici Yetkisi) oluşturuluyor
    let admin_cap = AdminCap {
        id: object::new(ctx)
    };

    // 2. Bu yetkiyi (Capability) modülü yayınlayan kişiye (deployer) gönderiyoruz
    transfer::public_transfer(admin_cap, tx_context::sender(ctx));
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {
    
    // Listeleme objesi için yeni bir ID oluşturuyoruz
    let id = object::new(ctx);

    // Event fırlatıyoruz (Objeyi oluşturmadan önce ID'sini alabiliriz)
    event::emit(HeroListed {
        list_hero_id: object::uid_to_inner(&id),
        price: price,
        seller: tx_context::sender(ctx),
        timestamp: ctx.epoch_timestamp_ms(),
    });

    // 1. ListHero objesini oluşturuyoruz (Hero'yu içine hapsediyoruz - Wrapping)
    let listing = ListHero {
        id: id,
        nft: nft,
        price: price,
        seller: tx_context::sender(ctx),
    };

    // 2. Obje herkes tarafından görülebilmesi ve satın alınabilmesi için paylaşıma açılıyor
    transfer::share_object(listing);
}

#[allow(lint(self_transfer))]
public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {

    // 1. Objeyi parçala (Unpack). Bu işlem ListHero kutusunu açar ve içindekileri çıkarır.
    let ListHero { id, nft, price, seller } = list_hero;

    // 2. Ödenen miktar ile fiyatı kontrol et. Yanlışsa işlemi iptal et (abort).
    assert!(coin::value(&coin) == price, EInvalidPayment);

    // 3. Parayı satıcıya gönder
    transfer::public_transfer(coin, seller);

    // 4. Hero'yu (NFT) satın alana (buyer/sender) gönder
    transfer::public_transfer(nft, tx_context::sender(ctx));

    // Event fırlat (İşlem başarılı)
    event::emit(HeroBought {
        list_hero_id: object::uid_to_inner(&id),
        price: price,
        buyer: tx_context::sender(ctx),
        seller: seller,
        timestamp: ctx.epoch_timestamp_ms(),
    });

    // 5. Artık işlevi biten ListHero objesinin ID'sini sil
    object::delete(id);
}

// ========= ADMIN FUNCTIONS =========

public fun delist(_: &AdminCap, list_hero: ListHero) {
    
    // 1. Objeyi parçala ama 'price' ile ilgilenmiyoruz (ignore syntax: price: _)
    let ListHero { id, nft, price: _, seller } = list_hero;

    // 2. NFT'yi asıl sahibine (listeyi oluşturan kişiye) geri gönder
    transfer::public_transfer(nft, seller);

    // 3. Listeleme ID'sini sil
    object::delete(id);
}

public fun change_the_price(_: &AdminCap, list_hero: &mut ListHero, new_price: u64) {
    
    // 1. Referans (&mut) üzerinden fiyatı güncelle
    list_hero.price = new_price;
}

// ========= GETTER FUNCTIONS =========

#[test_only]
public fun listing_price(list_hero: &ListHero): u64 {
    list_hero.price
}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, ctx.sender());
}

