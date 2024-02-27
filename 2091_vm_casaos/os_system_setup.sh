#!/bin/bash

# [x] read the variables from the env files
#VSCODE_PASSKEY=$(cat /home/abc/.env/secret_VSCODE_PASSKEY)
USER_NAME=$USER

# ---------------------------------------------------
# [x] Update the system and install required softwares
sudo apt-get update
sudo apt-get upgrade -y 

# ---------------------------------------------------
# [x] Install casaos
curl -fsSL https://get.casaos.io | sudo bash


# [x] Configure the firewall for code-access
sudo ufw allow 80/tcp

################################################
#### cleaning up
echo "**** clean up ****"
sudo rm -rf /config/* /tmp/* /var/lib/apt/lists/* /var/tmp/*
sudo apt-get -y clean
sudo apt-get -y autoclean 
sudo apt-get -y autoremove
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /home/$USER_NAME/.env
