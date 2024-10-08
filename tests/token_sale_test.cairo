
use token_sale::interfaces::token_sale::{ITokenSaleDispatcher, ITokenSaleDispatcherTrait};
use core::starknet::{get_caller_address, ContractAddress, contract_address_const};
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address
};

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let owner = contract_address_const::<'owner'>();
    let constructor_params = array![owner.into()];
    let (contract_address, _) = contract.deploy(@constructor_params).unwrap();
    contract_address
}

#[test]
fn test_constructor() {
    let contract_address = deploy_contract("TokenSale");
    let token_sale_dispatcher = ITokenSaleDispatcher { contract_address };
    let owner = contract_address_const::<'owner'>();
    
    assert(token_sale_dispatcher.get_token_sale_name() == "TokenSaleToken", 'Wrong token name.');
    assert(token_sale_dispatcher.get_token_sale_symbol() == "TS", 'Wrong symbol name');
    assert(token_sale_dispatcher.get_token_sale_owner() == owner, 'Wrong owner');
}

#[test]
#[should_panic(expected: 'Wrong owner')]
fn test_constructor_wrong_owner() {
    let contract_address = deploy_contract("TokenSale");
    let token_sale_dispatcher = ITokenSaleDispatcher { contract_address };
    
    assert(token_sale_dispatcher.get_token_sale_name() == "TokenSaleToken", 'Wrong token name.');
    assert(token_sale_dispatcher.get_token_sale_symbol() == "TS", 'Wrong symbol name');
    assert(token_sale_dispatcher.get_token_sale_owner() == get_caller_address(), 'Wrong owner');
}


#[test]
fn test_mint_owner() {
    let contract_address = deploy_contract("TokenSale");
    let token_sale_dispatcher = ITokenSaleDispatcher { contract_address };

    let owner = contract_address_const::<'owner'>();
    start_cheat_caller_address(contract_address, owner);

    token_sale_dispatcher.mint(1_000_000);
    assert(token_sale_dispatcher.get_token_sale_total_supply() == 1_000_000, 'Wrong total supply');

    token_sale_dispatcher.mint(123_000);
    assert(token_sale_dispatcher.get_token_sale_total_supply() == 1_123_000, 'Wrong total supply');

    stop_cheat_caller_address(contract_address);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn test_mint_not_owner() {
    let contract_address = deploy_contract("TokenSale");
    let token_sale_dispatcher = ITokenSaleDispatcher { contract_address };

    let not_owner = contract_address_const::<'not_owner'>();

    start_cheat_caller_address(contract_address, not_owner);
    token_sale_dispatcher.mint(1_000_000);
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_change_owner() {
    let contract_address = deploy_contract("TokenSale");
    let token_sale_dispatcher = ITokenSaleDispatcher { contract_address };

    let old_owner = contract_address_const::<'owner'>();
    let new_owner = contract_address_const::<'new_owner'>();
    start_cheat_caller_address(contract_address, old_owner);
    token_sale_dispatcher.set_new_owner(new_owner);

    stop_cheat_caller_address(contract_address);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn change_owner_not_owner() {
    let contract_address = deploy_contract("TokenSale");
    let token_sale_dispatcher = ITokenSaleDispatcher { contract_address };

    let not_owner = contract_address_const::<'not_owner'>();
    let new_owner = contract_address_const::<'new_owner'>();

    start_cheat_caller_address(contract_address, not_owner);
    token_sale_dispatcher.set_new_owner(new_owner);
    stop_cheat_caller_address(contract_address);
}
