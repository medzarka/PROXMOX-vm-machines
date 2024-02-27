#!/bin/sh


# [x] read the variables from the env files
echo '---------------------------------------------------'
echo ''
echo 'read the variables from the env files'
echo ''
CLOUDFLARE_TUNNEL_KEY=$(cat /home/abc/.env/secret_CLOUDFLARE_TUNNEL_KEY)
TAILSCALE_AUTH_KEY=$(cat /home/abc/.env/secret_TAILSCALE_AUTH_KEY)
USER_NAME=$USER


# [x] Update the system and install required softwares
echo '---------------------------------------------------'
echo ''
echo 'Update the system and install required softwares'
echo ''
sudo apt-get update
sudo apt-get upgrade -y
sudo sync

# [x] Install and configure Cloudflare client
echo '---------------------------------------------------'
echo ''
echo 'Install and configure Cloudflare client'
echo ''
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
sudo cloudflared service install $CLOUDFLARE_TUNNEL_KEY
sudo sync

# [x] Install and configure Tailscale client
echo '---------------------------------------------------'
echo ''
echo 'Install and configure Tailscale client'
echo ''
# One-command install, from https://tailscale.com/download/
curl -fsSL https://tailscale.com/install.sh | bash

# Set sysctl settings for IP forwarding (useful when configuring an exit node)
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf 
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf 
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# Generate an auth key from your Admin console
# https://login.tailscale.com/admin/settings/keys and replace the placeholder below
tailscale up --authkey=$TAILSCALE_AUTH_KEY

# Optional: Include this line to make this node available over Tailscale SSH
tailscale set --ssh

# Optional: Include this line to configure this machine as an exit node
tailscale set --advertise-exit-node

sudo sync



################################################
#### cleaning up
echo '---------------------------------------------------'
echo ''
echo 'System cleaning ...'
echo ''
echo "**** clean up ****"
sudo rm -rf /config/* /tmp/* /var/lib/apt/lists/* /var/tmp/*
sudo apt-get -y clean
sudo apt-get -y autoclean 
sudo apt-get -y autoremove
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /home/$USER_NAME/.env




echo ''
echo 'Done.'
echo ''


