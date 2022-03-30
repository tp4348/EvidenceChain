#!/bin/sh

BOOTNODE_IP=127.0.0.1

# Clean current network configuration
rm -rf bootnode/*
rm -rf node1/*
rm -rf miner/*

# Apply new configuration
geth init --datadir bootnode/ genesis.json
geth init --datadir node1/ genesis.json
geth init --datadir miner/ genesis.json

# Configures and runs bootnode
geth --datadir bootnode/ --networkid 15 --nat extip:$BOOTNODE_IP
BOOTNODEID=$(geth attach bootnode/geth.ipc --exec admin.nodeInfo.enr)

# TODO: Restrict to local network
# geth <other-flags> --netrestrict 172.16.254.0/24

# Run nodes
# For some apparent reason all those flags are neccesery to be able to:
# - get accounts inside node
# - unlock account inside a node
# - deploy smart contract using truffle to the node
geth --datadir node1 --networkid 15 --port 30305 --bootnodes $BOOTNODEID 

geth --datadir miner --networkid 15 --port 30307 --bootnodes $BOOTNODEID --mine --miner.threads=4 --miner.etherbase=0xA36d45D2E725bcD693c47b89FF8081be2e4a39A5 --metrics --keystore ~/.ethereum/keystore --http --allow-insecure-unlock --http.addr '0.0.0.0' --http.corsdomain "*" --http.port 8545 --http.api 'personal,eth,net,web3,txpool,miner'

# Check online peers
geth attach bootnode/geth.ipc --exec admin.peers