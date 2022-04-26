#!/usr/bin/env bash
export $(cat .env | xargs)
ganache --fork.url https://rinkeby.infura.io/v3/${INFURA_API_KEY} \
  --wallet.unlockedAccounts 0xC5aF91F7D10dDe118992ecf536Ed227f276EC60D \
  --wallet.unlockedAccounts 0xA5947832E55D150B9d1BAB59126Fda9830fcd993 \
  --wallet.defaultBalance 1000000 \
  --port 9545 \
  --miner.defaultGasPrice 55000000000