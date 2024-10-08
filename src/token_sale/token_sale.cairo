#[starknet::contract]
pub mod TokenSale {
    use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::{ContractAddress, get_caller_address};
    use token_sale::interfaces::token_sale::{ITokenSale};

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    pub struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
        OwnableEvent: OwnableComponent::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        let name = "TokenSaleToken";
        let symbol = "TS";

        self.erc20.initializer(name, symbol);
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl TokenSaleImpl of ITokenSale<ContractState> {
        fn mint(ref self: ContractState, amount: u256) {
            self.ownable.assert_only_owner();
            let caller = get_caller_address();

            self.erc20.mint(caller, amount);
        }

        fn get_token_sale_name(self: @ContractState) -> ByteArray {
            self.erc20.name()
        }

        fn get_token_sale_symbol(self: @ContractState) -> ByteArray {
            self.erc20.symbol()
        }

        fn get_token_sale_total_supply(self: @ContractState) -> u256 {
            self.erc20.total_supply()
        }

        fn get_token_sale_owner(self: @ContractState) -> ContractAddress {
            self.ownable.owner()
        }

        fn set_new_owner(ref self: ContractState, new_owner: ContractAddress) {
            self.ownable.transfer_ownership(new_owner);
        }
    }
}
