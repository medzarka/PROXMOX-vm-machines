#!/bin/bash

# [x] read the variables from the env files
VSCODE_PASSKEY=$(cat /home/abc/.env/secret_VSCODE_PASSKEY)
USER_NAME=$USER

# ---------------------------------------------------
# [x] Update the system and install required softwares

# [x] Create user ssh keys
ssh-keygen -P "" -q -m PEM -t rsa -b 4096 -C "$USER_NAME@code-server" -N '' -f /home/$USER_NAME/.ssh/id_rsa <<<y >/dev/null 2>&1

################################################
#### cleaning up
echo "**** clean up ****"
sudo rm -rf /config/* /tmp/* /var/lib/apt/lists/* /var/tmp/*
sudo apt-get -y clean
sudo apt-get -y autoclean 
sudo apt-get -y autoremove
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /home/$USER_NAME/.env
