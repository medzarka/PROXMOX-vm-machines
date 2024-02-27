#!/bin/bash


# list of templates  --> https://github.com/coder/awesome-coder?tab=readme-ov-file
# [x] read the variables from the env files
CODER_ACCESS_URL=$(cat /home/abc/.env/secret_CODER_ACCESS_URL)
USER_NAME=$USER


# [x] Update the system and install required softwares
echo '---------------------------------------------------'
echo ''
echo 'Update the system and install required softwares'
echo ''
sudo apt-get update
sudo apt-get upgrade -y
#sudo apt-get dist-upgrade -y
sudo sync

# [x] Install Docker
echo '---------------------------------------------------'
echo ''
echo 'Install Docker'
echo ''


for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
#sudo docker run hello-world # tock check


sudo groupadd docker
sudo usermod -aG docker $USER_NAME
newgrp docker

docker run hello-world

sudo chown "$USER_NAME":"$USER_NAME" /home/"$USER_NAME"/.docker -R
sudo chmod g+rwx "$USER_NAME/.docker" -R

sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl restart docker.service
sudo systemctl restart containerd.service
sudo sync

# [x] Install postgresql
echo '---------------------------------------------------'
echo ''
echo 'Install postgresql'
echo ''
sudo apt install postgresql postgresql-contrib
sudo systemctl restart postgresql
sudo systemctl status postgresql
sudo sync

# [x] Install Coder
echo '---------------------------------------------------'
echo ''
echo 'Install Coder'
echo ''
wget https://github.com/coder/coder/releases/download/v2.8.3/coder_2.8.3_linux_amd64.deb \
    -O /tmp/coder_2.8.3_linux_amd64.deb
sudo apt install /tmp/coder_2.8.3_linux_amd64.deb -y
coder --version # to check id coder is well installed.
sudo sync

#wget https://downloads.nestybox.com/sysbox/releases/v0.6.3/sysbox-ce_0.6.3-0.linux_amd64.deb \
#    -O /tmp/sysbox-ce_0.6.3-0.linux_amd64.deb
#sudo apt-get install jq -y
#sudo apt-get install /tmp/sysbox-ce_0.6.3-0.linux_amd64.deb -y

# [x] Configure Coder
echo '---------------------------------------------------'
echo ''
echo 'Configure Coder'
echo ''
CODER_PG_CONNECTION_URL=$(coder server postgres-builtin-url)

sudo tee /etc/coder.d/coder.env >/dev/null <<EOF
# String. Specifies the external URL (HTTP/S) to access Coder.
CODER_ACCESS_URL=$CODER_ACCESS_URL

# String. Address to serve the API and dashboard.
CODER_HTTP_ADDRESS=0.0.0.0:80

# String. The URL of a PostgreSQL database to connect to. If empty, PostgreSQL binaries
# will be downloaded from Maven (https://repo1.maven.org/maven2) and store all
# data in the config root. Access the built-in database with "coder server postgres-builtin-url".
CODER_PG_CONNECTION_URL=$CODER_PG_CONNECTION_URL

# Boolean. Specifies if TLS will be enabled.
CODER_TLS_ENABLE=

# If CODER_TLS_ENABLE=true, also set:
CODER_TLS_ADDRESS=0.0.0.0:443

# String. Specifies the path to the certificate for TLS. It requires a PEM-encoded file.
# To configure the listener to use a CA certificate, concatenate the primary
# certificate and the CA certificate together. The primary certificate should
# appear first in the combined file.
CODER_TLS_CERT_FILE=

# String. Specifies the path to the private key for the certificate. It requires a
# PEM-encoded file.
CODER_TLS_KEY_FILE=

# To solve the ::Node uses WebSockets because the "Upgrade: DERP" header may be blocked on the load balancer.:: issue
CODER_DERP_CONFIG_URL: "https://controlplane.tailscale.com/derpmap/default"
CODER_DERP_SERVER_ENABLE: "false"

EOF

sudo ufw allow 80
sudo ufw allow 443
sudo sync

# [x] Start Coder
echo '---------------------------------------------------'
echo ''
echo 'Start Coder'
echo ''

# Use systemd to start Coder now and on reboot
sudo systemctl enable --now coder
#sudo systemctl enable --now sysbox
# View the logs to ensure a successful start
journalctl -u coder.service -b
# To restart Coder after applying system changes:
sudo systemctl restart coder
#sudo systemctl restart sysbox

sudo systemctl status coder

# Add coder user to Docker group
sudo adduser $USER_NAME docker
newgrp docker
# Restart Coder server
sudo systemctl restart coder
# Test Docker
sudo -u coder docker ps
sudo sync

# [x] Create user ssh keys
echo '---------------------------------------------------'
echo ''
echo 'Create user ssh keys'
echo ''
ssh-keygen -P "" -q -m PEM -t rsa -b 4096 -C "$USER_NAME@code-server" -N '' -f /home/$USER_NAME/.ssh/id_rsa <<<y >/dev/null 2>&1
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


# https://github.com/matifali/coder-templates/blob/main/matlab-cpu/README.md

echo ''
echo 'Done.'
echo ''
