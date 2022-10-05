# ks-limit-order-sc
Demo Zap In contract


## Install lib
`forge install openzeppelin/openzeppelin-contracts@v3.4.1`

## Run script
`forge script script/DZapIn.s.sol --rpc-url $GOERLI_RPC --private-key $PRIVATE_KEY --broadcast --verify`

## Flatten contract
`forge flatten src/mock/BasicToken.sol --output src/mock/BasicTokenFlatten.sol`

## Load source to remix
`remixd -s <LINK_TO_SOURCE> --read-only -u https://remix.ethereum.org/`

## Data
1. Max UINT: 115792089237316195423570985008687907853269984665640564039457584007913129639935
2. Pool BT - BSB: 0x575bF13ADc6F62dE45653296d74507086701bf5e
3. Pool BT - WETH: 0xD1569f094224987800638ad9E6dCB91B71d6161F
4. Convert eth to wei: https://eth-converter.com/
5. Deadline for transaction: 2524582800 (Jan 1, 2050)

## Steps to deploy
1. Deploy Factory : 0xFA9e4af454A5351e3a572Adf468216f0E509BE41
2. Deploy WETH : 0x557D884cE3094057c8DbdEb3fe02c67b74782653
3. Deploy Basic Token : 0x2e8D557C537A37A075612E8f1903B62847Bd5c05
4. Deploy Basic Token 2: 0x94330cCf92B16D02919258b3da701Ff2DA507f0f
5. Deploy Router : 0x8A6729c704b1d7042843960E2fe14d3D011e2dff
6. Deploy Zap : 0xBeea7b7c4107e3124724bf36eE058Ca2Ae6aA44A
7. Approve token for Zap so user can zapIn
8. Approve LP token for Zap so user can zapOut