#!/bin/bash

# [x] read the variables from the env files
VSCODE_PASSKEY=$(cat /home/abc/.env/secret_VSCODE_PASSKEY)
USER_NAME=$USER

# ---------------------------------------------------
# [x] Update the system and install required softwares
sudo apt-get update
sudo apt-get upgrade -y


# [x] Install Coder
wget https://github.com/coder/coder/releases/download/v2.8.3/coder_2.8.3_linux_amd64.deb \
    -O /tmp/coder_2.8.3_linux_amd64.deb
sudo apt install /tmp/coder_2.8.3_linux_amd64.deb
coder --version # to check id coder is well installed.

# [x] Configure Coder
CODER_ACCESS_URL=$(sudo cat /root/ server postgres-builtin-url)
CODER_PG_CONNECTION_URL=$(sudo coder server postgres-builtin-url)

sudo tee /etc/coder.d/coder.env >/dev/null <<EOF
# String. Specifies the external URL (HTTP/S) to access Coder.
CODER_ACCESS_URL=$CODER_ACCESS_URL

# String. Address to serve the API and dashboard.
CODER_HTTP_ADDRESS=0.0.0.0:3000

# String. The URL of a PostgreSQL database to connect to. If empty, PostgreSQL binaries
# will be downloaded from Maven (https://repo1.maven.org/maven2) and store all
# data in the config root. Access the built-in database with "coder server postgres-builtin-url".
CODER_PG_CONNECTION_URL=$CODER_PG_CONNECTION_URL

# Boolean. Specifies if TLS will be enabled.
CODER_TLS_ENABLE=

# If CODER_TLS_ENABLE=true, also set:
CODER_TLS_ADDRESS=0.0.0.0:3443

# String. Specifies the path to the certificate for TLS. It requires a PEM-encoded file.
# To configure the listener to use a CA certificate, concatenate the primary
# certificate and the CA certificate together. The primary certificate should
# appear first in the combined file.
CODER_TLS_CERT_FILE=

# String. Specifies the path to the private key for the certificate. It requires a
# PEM-encoded file.
CODER_TLS_KEY_FILE=
EOF

sudo ufw allow 3000
sudo ufw allow 3443

# [x] Start Coder

# Use systemd to start Coder now and on reboot
sudo systemctl enable --now coder
# View the logs to ensure a successful start
journalctl -u coder.service -b
# To restart Coder after applying system changes:
sudo systemctl restart coder



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
