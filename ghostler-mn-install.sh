#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended operating system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Ghostler   masternodes.     *"
echo "*                                                                          *"
echo "*        IPv6 will be used if available                                    *"
echo "*                                                                          *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [ $DOSETUP = "y" ]
then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get update
  sudo apt-get install -y zip unzip

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd

  wget https://github.com/ghostler/ghostler/releases/download/v1.0.0/Linux.zip
  unzip Linux.zip
  chmod +x Linux/bin/*
  sudo mv  Linux/bin/* /usr/local/bin
  rm -rf Linux.zip Windows Linux Mac

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
fi

 ## Setup conf
 IP=$(curl -k https://ident.me)
 mkdir -p ~/bin
 echo ""
 echo "Configure your masternodes now!"
 echo "Detecting IP address:$IP"

  echo ""
  echo "Enter alias for new node"
  read ALIAS

  echo ""
  echo "Enter port for node $ALIAS"
  echo "Just press enter"
  DEFAULTPORT=13815
  PORT=13815
  
  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  RPCPORT=13816
  echo "The RPC port is $RPCPORT"

  ALIAS=${ALIAS}
  CONF_DIR=~/.ghr_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/ghrd_$ALIAS.sh
  echo "ghrd -daemon -conf=$CONF_DIR/ghr.conf -datadir=$CONF_DIR "'$*' >> ~/bin/ghrd_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/ghr-cli_$ALIAS.sh
  echo "ghr-cli -conf=$CONF_DIR/ghr.conf -datadir=$CONF_DIR "'$*' >> ~/bin/ghr-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/ghr-tx_$ALIAS.sh
  echo "ghr-tx -conf=$CONF_DIR/ghr.conf -datadir=$CONF_DIR "'$*' >> ~/bin/ghr-tx_$ALIAS.sh
  chmod 755 ~/bin/ghr*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> ghr.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ghr.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> ghr.conf_TEMP
  echo "rpcport=$RPCPORT" >> ghr.conf_TEMP
  echo "listen=1" >> ghr.conf_TEMP
  echo "server=1" >> ghr.conf_TEMP
  echo "daemon=1" >> ghr.conf_TEMP
  echo "logtimestamps=1" >> ghr.conf_TEMP
  echo "maxconnections=256" >> ghr.conf_TEMP
  echo "masternode=1" >> ghr.conf_TEMP
  echo "port=$PORT" >> ghr.conf_TEMP
  echo "masternodeaddr="[$IP]":$PORT" >> ghr.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> ghr.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv ghr.conf_TEMP $CONF_DIR/ghr.conf

  sh ~/bin/ghrd_$ALIAS.sh
  
  
 echo
 echo -e "================================================================================================================================"
 echo -e "Ghostler coin Masternode is up and running and it is listening on port $PORT."
 echo -e "Please make sure the you use the [] when using IPv6 in the masternode config of local wallet" [$IP]:$PORT
 echo -e "MASTERNODE PRIVATEKEY is: $PRIVKEY"
 echo -e "================================================================================================================================"  
    

