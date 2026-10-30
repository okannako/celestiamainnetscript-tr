#!/bin/bash
echo -e "\033[0;37m"
echo "============================================================================================================"
echo " #####   ####        ####        ####  ####    ######    ##########  ####    ####  ###########   ####  ####"
echo " ######  ####       ######       #### ####    ########   ##########  ####    ####  ####   ####   #### ####"
echo " ####### ####      ###  ###      ########    ####  ####     ####     ####    ####  ####   ####   ########"
echo " #### #######     ##########     ########   ####    ####    ####     ####    ####  ###########   ########"
echo " ####  ######    ############    #### ####   ####  ####     ####     ####    ####  ####  ####    #### ####"
echo " ####   #####   ####      ####   ####  ####   ########      ####     ############  ####   ####   ####  ####"
echo " ####    ####  ####        ####  ####   ####    ####        ####     ############  ####    ####  ####   ####"
echo "============================================================================================================"
echo -e '\e[36mTwitter :\e[39m' https://twitter.com/TurkNako
echo -e '\e[36mGithub  :\e[39m' https://github.com/okannako
echo -e '\e[36mYoutube :\e[39m' https://www.youtube.com/@CryptoChainNakoTurk
echo -e "\e[0m"
sleep 5

CHAIN_ID="celestia"
APP_VERSION="v10.5.0"
NODE_VERSION="v0.34.4"
GO_VERSION="1.26.9"
CORE_IP="rpc.celestia.pops.one"
CORE_PORT="9090"

echo -e "\e[1m\e[32m Yapmak istediğin şey nedir ? \e[0m" && sleep 2
PS3='Select an action: '
options=(
"Validator Node Yüklemek"
"Validator Node Kontrol"
"Validator Oluşturmak"
"Fibre Sunucusu Yüklemek"
"Fibre Adresini Zincire Kaydetmek"
"Light Node Yüklemek"
"Bridge Node Yüklemek"
"Full Storage Node Yüklemek"
"Light Node Data Sıfırla"
"Bridge Node Data Sıfırla"
"Full Storage Node Data Sıfırla"
"Light Node ID Nedir ?"
"Bridge Node ID Nedir ?"
"Full Storage Node ID Nedir ?"
"Çıkış")
select opt in "${options[@]}"
do
case $opt in

"Validator Node Yüklemek")

echo -e "\e[1m\e[32m Güncellemeler \e[0m" && sleep 2

sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git ncdu lz4 -y
sudo apt install make -y
sleep 1

echo -e "\e[1m\e[32m Go Yükleniyor \e[0m" && sleep 2
ver="$GO_VERSION"
cd $HOME
wget "https://go.dev/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version && sleep 2

cd $HOME
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app/
git checkout tags/$APP_VERSION -b $APP_VERSION
make install
celestia-appd version && sleep 3

echo -e "\e[1m\e[32m bbr Aktif Ediliyor \e[0m" && sleep 2
make bbr-enable
cd $HOME

echo "NodeIsmi:"
read NodeIsmi
echo export NodeIsmi=${NodeIsmi} >> $HOME/.bash_profile

celestia-appd init "$NodeIsmi" --chain-id $CHAIN_ID

celestia-appd download-genesis $CHAIN_ID

SEEDS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/main/celestia/seeds.txt | tr '\n' ',' | sed 's/,$//')
PEERS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/main/celestia/peers.txt | tr '\n' ',' | sed 's/,$//')
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml

sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.celestia-app/config/app.toml

sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.002utia"|g' $HOME/.celestia-app/config/app.toml

# Fibre sunucusu için gRPC ve imzalayıcı (sadece 127.0.0.1, dışarı açılmaz)
sed -i -e '/^\[grpc\]/,/^\[/{s/^enable *=.*/enable = true/; s/^address *=.*/address = "127.0.0.1:9090"/}' $HOME/.celestia-app/config/app.toml
sed -i -e 's/^priv_validator_grpc_laddr *=.*/priv_validator_grpc_laddr = "127.0.0.1:26669"/' $HOME/.celestia-app/config/config.toml

celestia-appd tendermint unsafe-reset-all --home $HOME/.celestia-app

sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-appd.service
[Unit]
Description=Celestia node
After=network-online.target
[Service]
User=root
ExecStart=$(which celestia-appd) start --home $HOME/.celestia-app
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd

echo "CüzdanIsmi:"
read CuzdanIsmi
echo export CuzdanIsmi=${CuzdanIsmi} >> $HOME/.bash_profile
celestia-appd keys add $CuzdanIsmi

echo -e '\e[36mBu adımda cüzdanınızla ilgili bilgiler paylaşılır.. >>>LÜTFEN ANLATICI KELİMELERİ YEDEKLEYİN.<<< Yedekleme yaptıktan sonra Enter tuşuna basarak devam edebilirsiniz.\e[39m'
read Enter

echo -e '\e[36mIMPORTANT: Geçerli bloğa senkronizasyonu bekleyin. Kontrol etmek için betiği yeniden başlatın ve ilgili seçeneği seçin.\e[39m'
sleep 7
sudo journalctl -u celestia-appd -f

break
;;

"Validator Node Kontrol")

celestia-appd status 2>&1 | jq .sync_info
echo -e '\e[36mÖNEMLİ: "catching_up": false olduğunda, mevcut bloğa erişmişsinizdir ve betiği tekrar çalıştırıp Doğrulayıcı Oluşturabilirsiniz. Doğrulayıcı oluşturmadan önce cüzdanınıza TIA gönderdiğinizden emin olun. Aktif validator setine (ilk 100) girmek için 1 TIA.dan fazlası gerekir, güncel sınırı https://celenium.io üzerinden kontrol edin.\e[39m'
sleep 10

break
;;

"Validator Oluşturmak")

source $HOME/.bash_profile

celestia-appd tx staking create-validator \
--amount=1000000utia \
--pubkey=$(celestia-appd tendermint show-validator) \
--moniker=$NodeIsmi \
--chain-id=$CHAIN_ID \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=$CuzdanIsmi \
--gas-adjustment=1.4 \
--gas=auto \
--gas-prices=0.01utia

echo -e '\e[36mÖNEMLİ: Doğrulayıcı oluşturma adımı tamamlandıktan sonra .celestia-app klasöründeki config klasörünü yedeklediğinizden emin olun..\e[39m'
sleep 10

break
;;

"Fibre Sunucusu Yüklemek")

echo -e "\e[1m\e[32m Fibre Yükleniyor \e[0m" && sleep 2

APP_V=$(curl -s http://127.0.0.1:26657/abci_info | jq -r .result.response.app_version)
if [ "$APP_V" -lt 10 ] 2>/dev/null; then
echo -e '\e[31mHATA: Zincirde v10 henüz aktif değil veya node çalışmıyor. Önce validator node kurulu ve senkron olmalı.\e[39m'
break
fi

echo "Fibre verisinin tutulacağı klasör (celestia-app'ten farklı bir diskte olması önerilir, örnek: /data/fibre):"
read FIBRE_HOME
FIBRE_HOME=${FIBRE_HOME:-/data/fibre}
echo export FIBRE_HOME=${FIBRE_HOME} >> $HOME/.bash_profile
sudo mkdir -p $FIBRE_HOME

cd $HOME
wget https://github.com/celestiaorg/celestia-app/releases/download/$APP_VERSION/fibre_Linux_x86_64.tar.gz
wget https://github.com/celestiaorg/celestia-app/releases/download/$APP_VERSION/checksums.txt
sha256sum --ignore-missing --check checksums.txt
tar -xzf fibre_Linux_x86_64.tar.gz
sudo mv fibre /usr/local/bin/
rm fibre_Linux_x86_64.tar.gz checksums.txt
fibre version && sleep 3

sudo tee <<EOF >/dev/null /etc/systemd/system/fibre.service
[Unit]
Description=Celestia Fibre server
After=network-online.target celestia-appd.service
[Service]
User=root
ExecStart=/usr/local/bin/fibre start --home $FIBRE_HOME --app-grpc-address 127.0.0.1:9090 --signer-grpc-address 127.0.0.1:26669 --server-listen-address 0.0.0.0:7980
Restart=on-failure
RestartSec=5
TimeoutStopSec=120
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable fibre
sudo systemctl start fibre

echo -e '\e[36mÖNEMLİ: 7980 portu dışarıdan erişilebilir olmalı (sudo ufw allow 7980/tcp). 9090 ve 26669 portlarını kesinlikle dışarı açmayın. Fibre çalıştıktan sonra betiği tekrar çalıştırıp "Fibre Adresini Zincire Kaydetmek" seçeneğini seçin.\e[39m'
sleep 7
sudo journalctl -u fibre -f

break
;;

"Fibre Adresini Zincire Kaydetmek")

source $HOME/.bash_profile

echo "Sunucunuzun dışarıdan erişilen IP adresi veya alan adı:"
read FIBRE_HOST

celestia-appd tx valaddr set-host $FIBRE_HOST:7980 \
--from=$CuzdanIsmi \
--chain-id=$CHAIN_ID \
--gas-adjustment=1.4 \
--gas=auto \
--gas-prices=0.01utia

sleep 10
echo -e '\e[36mKayıt kontrolü (found: true görünmeli):\e[39m'
celestia-appd query valaddr provider $(celestia-appd comet show-address)

break
;;

"Light Node Yüklemek")

echo -e "\e[1m\e[32m Güncellemeler \e[0m" && sleep 2
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git ncdu -y
sudo apt install make -y
sleep 1

echo -e "\e[1m\e[32m Go Yüklemek \e[0m" && sleep 2
ver="$GO_VERSION"
cd $HOME
wget "https://go.dev/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version && sleep 2

cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout tags/$NODE_VERSION
make build
make install
make cel-key
celestia version && sleep 3
celestia light init --p2p.network celestia

echo -e '\e[36mBu adımda cüzdanınızla ilgili bilgiler paylaşılır.. >>>LÜTFEN ANLATICI KELİMELERİ YEDEKLEYİN.<<< Yedekleme yaptıktan sonra Enter tuşuna basarak devam edebilirsiniz.\e[39m'
read Enter

sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-lightd.service
[Unit]
Description=celestia-light Cosmos daemon
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/celestia light start --core.ip $CORE_IP --core.port $CORE_PORT --keyring.backend test --keyring.keyname my_celes_key --p2p.network celestia
Restart=on-failure
RestartSec=3
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable celestia-lightd
sudo systemctl start celestia-lightd

echo -e '\e[36mÖNEMLİ: /root/.celestia-light/keys klasörünün yedeklenmesi gerekir.\e[39m'
sleep 7

journalctl -u celestia-lightd.service -f

break
;;

"Bridge Node Yüklemek")

echo -e "\e[1m\e[32m Güncellemeler \e[0m" && sleep 2
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git ncdu -y
sudo apt install make -y
sleep 1

echo -e "\e[1m\e[32m Go Yüklemek \e[0m" && sleep 2
ver="$GO_VERSION"
cd $HOME
wget "https://go.dev/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version && sleep 2

cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout tags/$NODE_VERSION
make build
make install
make cel-key
celestia version && sleep 3

echo "NodeIsmi:"
read NodeIsmi
echo export NodeIsmi=${NodeIsmi} >> $HOME/.bash_profile

echo "Kendi consensus node'unuzun IP adresi (boş bırakırsanız $CORE_IP kullanılır):"
read MY_CORE_IP
BRIDGE_CORE_IP=${MY_CORE_IP:-$CORE_IP}

celestia bridge init --core.ip $BRIDGE_CORE_IP --core.port $CORE_PORT --p2p.network celestia

sudo tee /etc/systemd/system/celestia-bridge.service > /dev/null <<EOF
[Unit]
Description=celestia-bridge Cosmos daemon
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/celestia bridge start --core.ip $BRIDGE_CORE_IP --core.port $CORE_PORT --keyring.backend test --keyring.keyname my_celes_key --p2p.network celestia
Restart=on-failure
RestartSec=3
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable celestia-bridge
sudo systemctl start celestia-bridge

echo -e '\e[36mÖNEMLİ: /root/.celestia-bridge/keys klasörünün yedeklenmesi gerekir. Diğer node.ların sizi bulabilmesi için 2121 portu açık olmalı (sudo ufw allow 2121).\e[39m'
sleep 7

sudo journalctl -u celestia-bridge.service -f

break
;;

"Full Storage Node Yüklemek")

echo -e '\e[31mBİLGİ: Full storage node tipi celestia-node.dan kaldırıldı. Artık sadece bridge ve light node var. Bütün veriyi tutmak istiyorsanız bridge node kurup servis dosyasında start komutunun sonuna --archival ekleyin.\e[39m'
sleep 10

break
;;

"Light Node Data Sıfırla")

sudo systemctl stop celestia-lightd
celestia light unsafe-reset-store --p2p.network celestia
sudo systemctl restart celestia-lightd
journalctl -u celestia-lightd.service -f

break
;;

"Bridge Node Data Sıfırla")

sudo systemctl stop celestia-bridge
celestia bridge unsafe-reset-store --p2p.network celestia
sudo systemctl restart celestia-bridge
sudo journalctl -u celestia-bridge.service -f

break
;;

"Full Storage Node Data Sıfırla")

echo -e '\e[31mBİLGİ: Full storage node tipi kaldırıldı. Eski full node.unuzu tamamen silmek için: sudo systemctl stop celestia-fulld && sudo systemctl disable celestia-fulld && rm -rf $HOME/.celestia-full\e[39m'
sleep 10

break
;;

"Light Node ID Nedir ?")

AUTH_TOKEN=$(celestia light auth admin --p2p.network celestia)

curl -X POST \
     -H "Authorization: Bearer $AUTH_TOKEN" \
     -H 'Content-Type: application/json' \
     -d '{"jsonrpc":"2.0","id":0,"method":"p2p.Info","params":[]}' \
     http://localhost:26658

break
;;

"Bridge Node ID Nedir ?")

AUTH_TOKEN=$(celestia bridge auth admin --p2p.network celestia)

curl -X POST \
     -H "Authorization: Bearer $AUTH_TOKEN" \
     -H 'Content-Type: application/json' \
     -d '{"jsonrpc":"2.0","id":0,"method":"p2p.Info","params":[]}' \
     http://localhost:26658

break
;;

"Full Storage Node ID Nedir ?")

echo -e '\e[31mBİLGİ: Full storage node tipi kaldırıldı. Bridge node kullanıyorsanız "Bridge Node ID Nedir ?" seçeneğini seçin.\e[39m'
sleep 5

break
;;

"Çıkış")
exit
;;
*) echo "invalid option";;
esac
done
