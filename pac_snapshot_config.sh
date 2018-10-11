#!/bin/bash

set -e

if [ "$1" == "--testnet" ]; then
	pac_rpc_port=17111
	pac_port=17112
	is_testnet=1
else
	pac_rpc_port=7111
	pac_port=7112
	is_testnet=0
fi

echo "##########################################################"
echo "#   Welcome to PAC Masternode's snaspthot server setup   #"		
echo "##########################################################"
echo "" 
read -p 'Please provide the external IP: ' ipaddr
read -p 'Please provide masternode genkey: ' mnkey

while [[ $ipaddr = '' ]] || [[ $ipaddr = ' ' ]]; do
	read -p 'You did not provided an external IP, please provide one: ' ipaddr
	sleep 2
done

while [[ $mnkey = '' ]] || [[ $mnkey = ' ' ]]; do
	read -p 'You did not provided masternode genkey, please provide one: ' mnkey
	sleep 2
done

echo "###############################"
echo "#     Configure the wallet    #"		
echo "###############################"
echo ""
echo "The PacCoinCore config file will be created."

is_pac_running=`ps ax | grep -v grep | grep paccoind | wc -l`
if [ $is_pac_running -ne 0 ]; then
	echo "Stopping the daemon."
	~/paccoin-cli stop
	sleep 60
    
    is_pac_running=`ps ax | grep -v grep | grep paccoind | wc -l`
    if [ $is_pac_running -eq 0 ]; then
	    echo "The daemon has been stopped."
    fi
	
fi

if [ -d ~/.paccoincore ]; then
	if [ -e ~/.paccoincore/paccoin.conf ]; then
		
		sudo mv ~/.paccoincore/paccoin.conf ~/.paccoincore/paccoin.bak
		touch ~/.paccoincore/paccoin.conf
		cd ~/.paccoincore
	fi
else
	echo "Creating .paccoincore dir"
	mkdir -p ~/.paccoincore
	cd ~/.paccoincore
	touch paccoin.conf
fi

echo "Configuring the paccoin.conf"
echo "rpcuser=$(pwgen -s 16 1)" > paccoin.conf
echo "rpcpassword=$(pwgen -s 64 1)" >> paccoin.conf
echo "rpcallowip=127.0.0.1" >> paccoin.conf
echo "rpcport=$pac_rpc_port" >> paccoin.conf
echo "externalip=$ipaddr" >> paccoin.conf
echo "port=$pac_port" >> paccoin.conf
echo "server=1" >> paccoin.conf
echo "daemon=1" >> paccoin.conf
echo "listen=1" >> paccoin.conf
echo "testnet=$is_testnet" >> paccoin.conf
echo "masternode=1" >> paccoin.conf
echo "masternodeaddr=$ipaddr:$pac_port" >> paccoin.conf
echo "masternodeprivkey=$mnkey" >> paccoin.conf

echo "###############################"
echo "#      Running the wallet     #"		
echo "###############################"
echo ""
cd ~/

./paccoind
sleep 60

is_pac_running=`ps ax | grep -v grep | grep paccoind | wc -l`
if [ $is_pac_running -eq 0 ]; then
	echo "The daemon is not running or there is an issue, please restart the daemon!"
	exit
else
    rm ~/.paccoincore/paccoin.bak
    echo "This server has been configured successfuly."
    echo "Your masternode server is ready!"
    echo "Don't forget to run the masternode from your cold wallet!"
fi
