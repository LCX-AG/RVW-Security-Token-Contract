# RVW Security token

It contains two smart contracts,

1. RVW Token Contract
2. ERC1404 Contract


## Steps to Deploy

1. Deploy ERC1404 smart contract and get the contract address.
2. Then deploy the RVW token contract, where you havae to pass the ERC1404 contract in constructor, and get the token contract address
3. Call `updateChecker` function in ERC1404 contract with token contract address.

Now, it is ready to test the functionality.
