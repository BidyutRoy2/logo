# Installation

### Use our installation script, specify a name for your node and wait for the installation to complete

``` 
wget -q -O warden.sh https://raw.githubusercontent.com/BidyutRoy2/warden-protocol-node/main/warden.sh && sudo chmod +x warden.sh && ./warden.sh && source $HOME/.bash_profile
```

### Create a wallet, don’t forget to save the mnemonic:
```
wardend keys add wallet
```

### If you already have a wallet, you can recover with:
```
wardend keys add wallet --recover
```

### Request tokens at the faucet.
```
curl -XPOST -d '{"address": "YOUR_WALLET_ADDRESS"}' https://faucet.buenavista.wardenprotocol.org
```

### After full synchronization, check the balance, if everything is okay, proceed to create a validator.
```
wardend q bank balances $(wardend keys show wallet -a)
```

### Create a validator(You can add additional information about your validator in the file $HOME/.warden/validator.json):
```
wardend tx staking create-validator $HOME/.warden/validator.json \
    --from=wallet \
    --chain-id=buenavista-1 \
    --fees=500uward -y
```

# Additional

### View logs
```
sudo journalctl -u wardend -f
```

### Restart node:
```
sudo systemctl restart wardend
```

### Check node status:
```
curl localhost:26657/status
```

### Find out if the node is synchronized, if the result is false – it means the node is synchronized
```
curl -s localhost:26657/status | jq .result.sync_info.catching_up
```

### Find out your valoper address:
```
wardend keys show wallet --bech val -a
```

### Delegate tokens (to increase your stake delegate to your valoper address):
```
wardend tx staking delegate YOUR_VALOPER_ADDRESS 1000000uward --from wallet --chain-id buenavista-1 --fees=500uward -y
```

# Remove node:
```
sudo systemctl stop wardend
sudo systemctl disable wardend
sudo rm -rf $(which wardend) $HOME/.wardend
```

