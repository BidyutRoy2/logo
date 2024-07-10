#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
sleep 1 && curl -s https://github.com/BidyutRoy2/logo/blob/main/logo.sh | bash && sleep 1

NODE="wardend"
export DAEMON_HOME=$HOME/.warden
export DAEMON_NAME=wardend
if [ -d "$DAEMON_HOME" ]; then
    new_folder_name="${DAEMON_HOME}_$(date +"%Y%m%d_%H%M%S")"
    mv "$DAEMON_HOME" "$new_folder_name"
fi
#CHAIN_ID=zgtendermint_9000-1
#echo 'export CHAIN_ID='\"${CHAIN_ID}\" >> $HOME/.bash_profile

if [ ! $VALIDATOR ]; then
    read -p "Enter validator name: " VALIDATOR
    echo 'export VALIDATOR='\"${VALIDATOR}\" >> $HOME/.bash_profile
fi
echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
source $HOME/.bash_profile
sleep 1
cd $HOME
sudo apt update
sudo apt install make unzip clang pkg-config lz4 libssl-dev build-essential git jq ncdu bsdmainutils htop -y < "/dev/null"

echo -e '\n\e[42mInstall Go\e[0m\n' && sleep 1
cd $HOME
VERSION=1.21.9
wget -O go.tar.gz https://go.dev/dl/go$VERSION.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz && rm go.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
go version

echo -e '\n\e[42mInstall software\e[0m\n' && sleep 1

sleep 1
source .profile
cd $HOME
rm -rf wardenprotocol
git clone --depth 1 --branch v0.3.0 https://github.com/warden-protocol/wardenprotocol/
cd wardenprotocol
make build
sudo mv ./build/wardend /usr/local/bin/

#SEEDS="8c01665f88896bca44e8902a30e4278bed08033f@54.241.167.190:26656,b288e8b37f4b0dbd9a03e8ce926cd9c801aacf27@54.176.175.48:26656,8e20e8e88d504e67c7a3a58c2ea31d965aa2a890@54.193.250.204:26656,e50ac888b35175bfd4f999697bdeb5b7b52bfc06@54.215.187.94:26656"
$DAEMON_NAME init "${VALIDATOR}" --chain-id buenavista-1
sleep 1
$DAEMON_NAME config set client chain-id buenavista-1
$DAEMON_NAME config set client keyring-backend test
wget -O $HOME/.warden/config/genesis.json https://raw.githubusercontent.com/warden-protocol/networks/main/testnets/buenavista/genesis.json
#sed -i.bak -e "s/^seeds *=.*/seeds = \"${SEEDS}\"/" $DAEMON_HOME/config/config.toml
sed -i 's/^minimum-gas-prices *=.*/minimum-gas-prices = "0.0025uward"/' $DAEMON_HOME/config/app.toml
#sed -i 's/^persistent_peers *=.*/persistent_peers = "ddb4d92ab6eba8363bab2f3a0d7fa7a970ae437f@sentry-1.buenavista.wardenprotocol.org:26656,c717995fd56dcf0056ed835e489788af4ffd8fe8@sentry-2.buenavista.wardenprotocol.org:26656,e1c61de5d437f35a715ac94b88ec62c482edc166@sentry-3.buenavista.wardenprotocol.org:26656"/' $DAEMON_HOME/config/config.toml
PEERS="dace3198735a4c457d651ada8e5a6c3dc40f6ac6@161.97.118.43:34656,7411b437fcae714ccfc945d3798f54dafd802f43@149.102.147.128:17656,3c4c0c8fa63f7a6e1045506373b576612c188e60@4.206.216.119:26656,5add79f9552c33c8a26bb9497b5b3aed503ae7b7@161.97.113.249:26656,d5126141e065986f97e568c360b7b517ed2dc52a@5.75.159.246:26656,2a6e1a3968d7ecf77baaf1590f08350a7e356e29@164.68.105.199:11256,a5c006b0be397177d9787883bdf41f55af371cbe@84.247.162.147:26656,5d19e305ba809346d419853c4bc34480ed08c84e@207.244.224.103:26656,877b5f0a95e52938f02ecd555f1a3a11ebdf2df0@65.108.72.233:56656,67b61778e63da8a9bc8083eb465077ba731940c4@88.198.50.206:36656,d1022e9ba937d689b56c3d705318f42b7c990259@77.237.244.118:11256,231d30bae964b1a61140c422cc5cfba01be70da7@161.97.170.144:26656,7f6c095219b0ae2025b6ede827723477d467f0ee@109.199.123.151:46656,5a970e9ec4861ee1d75be17bc20564e5f232c7c9@65.109.112.148:22316,d3c5f8df0262d79d7a70f4ec7f1dcf0f4041f36b@84.247.189.90:18656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.warden/config/config.toml

echo "[Unit]
Description=$NODE Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/$DAEMON_NAME start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/$NODE.service
sudo mv $HOME/$NODE.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

echo -e '\n\e[42mDownloading a snapshot\e[0m\n' && sleep 1
curl https://snapshots.nodes.guru/warden/latest_snapshot.tar.lz4 | lz4 -dc - | tar -xf - -C $DAEMON_HOME
wget -O $DAEMON_HOME/config/addrbook.json https://snapshots.nodes.guru/warden/addrbook.json

echo -e '\n\e[42mChecking a ports\e[0m\n' && sleep 1
#CHECK PORTS
PORT=336
if ss -tulpen | awk '{print $5}' | grep -q ":26656$" ; then
    echo -e "\e[31mPort 26656 already in use.\e[39m"
    sleep 2
    sed -i -e "s|:26656\"|:${PORT}56\"|g" $DAEMON_HOME/config/config.toml
    echo -e "\n\e[42mPort 26656 changed to ${PORT}56.\e[0m\n"
    sleep 2
fi
if ss -tulpen | awk '{print $5}' | grep -q ":26657$" ; then
    echo -e "\e[31mPort 26657 already in use\e[39m"
    sleep 2
    sed -i -e "s|:26657\"|:${PORT}57\"|" $DAEMON_HOME/config/config.toml
    echo -e "\n\e[42mPort 26657 changed to ${PORT}57.\e[0m\n"
    sleep 2
    $DAEMON_NAME config set client node tcp://localhost:${PORT}57
fi
if ss -tulpen | awk '{print $5}' | grep -q ":26658$" ; then
    echo -e "\e[31mPort 26658 already in use.\e[39m"
    sleep 2
    sed -i -e "s|:26658\"|:${PORT}58\"|" $DAEMON_HOME/config/config.toml
    echo -e "\n\e[42mPort 26658 changed to ${PORT}58.\e[0m\n"
    sleep 2
fi
if ss -tulpen | awk '{print $5}' | grep -q ":6060$" ; then
    echo -e "\e[31mPort 6060 already in use.\e[39m"
    sleep 2
    sed -i -e "s|:6060\"|:${PORT}60\"|" $DAEMON_HOME/config/config.toml
    echo -e "\n\e[42mPort 6060 changed to ${PORT}60.\e[0m\n"
    sleep 2
fi
if ss -tulpen | awk '{print $5}' | grep -q ":1317$" ; then
    echo -e "\e[31mPort 1317 already in use.\e[39m"
    sleep 2
    sed -i -e "s|:1317\"|:${PORT}17\"|" $DAEMON_HOME/config/app.toml
    echo -e "\n\e[42mPort 1317 changed to ${PORT}17.\e[0m\n"
    sleep 2
fi
if ss -tulpen | awk '{print $5}' | grep -q ":9090$" ; then
    echo -e "\e[31mPort 9090 already in use.\e[39m"
    sleep 2
    sed -i -e "s|:9090\"|:${PORT}90\"|" $DAEMON_HOME/config/app.toml
    echo -e "\n\e[42mPort 9090 changed to ${PORT}90.\e[0m\n"
    sleep 2
fi

#echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable $NODE
sudo systemctl restart $NODE

tee $DAEMON_HOME/validator.json > /dev/null << EOF
{
    "pubkey": $(wardend comet show-validator),
    "amount": "1000000uward",
    "moniker": "${VALIDATOR}",
    "identity": "",
    "website": "",
    "security": "",
    "details": "",
    "commission-rate": "0.1",
    "commission-max-rate": "0.2",
    "commission-max-change-rate": "0.01",
    "min-self-delegation": "1"
}
EOF

echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service $NODE status | grep active` =~ "running" ]]; then
  echo -e "Your $NODE node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice 0g status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your $NODE node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
