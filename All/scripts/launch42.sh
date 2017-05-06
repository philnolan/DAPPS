#!/bin/bash

# Run this once, but it does not hurt to run it every time
geth --datadir ~/.ethereum/net42 init ~/Documents/genesis42.json
# Run this every time you start your Geth "42"
geth --datadir ~/.ethereum/net42 --networkid 42 --rpc --rpcport 8545 --rpcaddr 0.0.0.0 --rpccorsdomain "*" --rpcapi "eth,net,web3" console
