use starknet::ContractAddress;

#[starknet::interface]
pub trait ITokenSale<TContractState> {
    fn mint(ref self: TContractState, amount: u256);
    fn get_token_sale_name(self: @TContractState) -> ByteArray;
    fn get_token_sale_symbol(self: @TContractState) -> ByteArray;
    fn get_token_sale_total_supply(self: @TContractState) -> u256;
    fn get_token_sale_owner(self: @TContractState) -> ContractAddress;
    fn set_new_owner(ref self: TContractState, new_owner: ContractAddress);
}
