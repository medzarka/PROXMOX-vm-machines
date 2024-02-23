#!/bin/bash


# https://www.vanwerkhoven.org/blog/2022/home-server-configuration/#proxmox
# https://blog.kroy.io/2020/05/04/vyos-from-scratch-edition-1/#WAN_and_Zones
# https://blog.cavelab.dev/2022/04/virtual-vyos-router/

# [x] read the variables from the env files
#VSCODE_PASSKEY=$(cat /home/abc/.env/secret_VSCODE_PASSKEY)
USER_NAME=$USER


# [x] Update the system
echo ""
echo "---------------------------------------------------------------"
echo "Update the system"
echo ""
sudo apt-get update
sudo apt-get upgrade -y 
sudo apt-get install unzip -y 
################################################
#### cleaning up
echo "**** clean up ****"
sudo rm -rf /config/* /tmp/* /var/lib/apt/lists/* /var/tmp/*
sudo apt-get -y clean
sudo apt-get -y autoclean 
sudo apt-get -y autoremove
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /home/$USER_NAME/.env
