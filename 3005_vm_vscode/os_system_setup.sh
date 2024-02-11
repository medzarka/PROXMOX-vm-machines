
# [x] read the variables from the env files
VSCODE_PASSKEY=$(cat /home/abc/.env/secret_VSCODE_PASSKEY)
USER_NAME=$USER

# ---------------------------------------------------
# [x] Update the system and install required softwares
sudo apt-get update
sudo apt-get upgrade -y 
sudo apt-get install -y --no-install-recommends   \
  htop wget ca-certificates curl llvm net-tools iputils-ping nano openssh-server less sudo gpg \
  make git build-essential locales locales-all kmod file bash-completion tzdata gettext clang \
  postgresql-client postgresql-common libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev mecab-ipadic-utf8 \
  jq libatomic1 python3-dev python3-setuptools libtiff5-dev libjpeg-dev libopenjp2-7-dev zlib1g-dev \
  libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python3-tk \
  libharfbuzz-dev libfribidi-dev libxcb1-dev \
  pandoc unzip zip

echo "**** install C/C++ packages ****" 
sudo apt-get install -y --no-install-recommends g++ gdb gcc

echo "**** install octave packages ****" 
sudo apt-get install -y --no-install-recommends octave octave-image octave-signal octave-audio octave-common

echo "**** install rust packages ****" 
sudo apt-get install -y --no-install-recommends rustc
  

# [x] Install and configure code-server
################################################
#### Install cs-code server
echo "**** install code-server ****"
MACHINE_ARCH=$(dpkg-architecture -q DEB_BUILD_ARCH)
CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); 
sudo mkdir -p /app/code-server
sudo curl -o /tmp/code-server.tar.gz -L "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-${MACHINE_ARCH}.tar.gz"
sudo tar xf /tmp/code-server.tar.gz -C /app/code-server --strip-components=1

mkdir -p /home/$USER_NAME/vscode/config/extensions
mkdir -p /home/$USER_NAME/vscode/config/data
mkdir -p /home/$USER_NAME/vscode/config/workspace
# fix permissions (ignore contents of /config/workspace)
find /home/$USER_NAME/vscode/config/ -path /home/$USER_NAME/vscode/config/workspace -prune -o -exec chown $USER_NAME:$USER_NAME {} +
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/vscode
sudo chown -R $USER_NAME:$USER_NAME /app/code-server


sudo tee /etc/systemd/system/code-server.service >/dev/null <<EOF
[Unit]
Description=code-server

[Service]
User=$USER_NAME
WorkingDirectory=/home/$USER_NAME
ExecStart=/app/code-server/bin/code-server --bind-addr 0.0.0.0:8080 --user-data-dir /home/$USER_NAME/vscode/config/data --extensions-dir /home/$USER_NAME/vscode/config/extensions --disable-telemetry --auth password /home/$USER_NAME/vscode/config/workspace
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start code-server
sudo systemctl enable code-server

sed -r -i "s/password:.*/password: $VSCODE_PASSKEY/g" /home/$USER_NAME/.config/code-server/config.yaml
sed -r -i "s/bind-addr:.*/bind-addr: 0.0.0.0:8080/g" /home/$USER_NAME/.config/code-server/config.yaml

sudo systemctl restart code-server


# [x] Configure the firewall for code-access
sudo ufw allow 8080/tcp

################################################

# [x] Install pyenv

sudo chown -R $USER_NAME:$USER_NAME /app/
#mkdir -p /app/pyenv
export PYENV_ROOT=/app/pyenv
export PATH=${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:$PATH
export PYENV_PYTHON_VERSION=3.11
curl https://pyenv.run | bash 
pyenv update 
pyenv install ${PYENV_PYTHON_VERSION}
pyenv global ${PYENV_PYTHON_VERSION}
pyenv rehash
pip install --upgrade pip
pip install --upgrade wheel


tee /home/$USER_NAME/.bashrc >/dev/null <<EOF
#
#
# Start: Pyenv configuration
#
export PYENV_ROOT=/app/pyenv
export PATH=\$PYENV_ROOT/shims:\$PYENV_ROOT/bin:\$PATH
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"
#
# End: Pyenv configuration
#
#
EOF
source /home/$USER_NAME/.bashrc

################################################
# [x] Install sdkman
#sudo mkdir -p /app/sdkman
export SDKMAN_DIR=/app/sdkman
curl -s "https://get.sdkman.io" | bash
source "$SDKMAN_DIR/bin/sdkman-init.sh"
#source "/app/sdkman/bin/sdkman-init.sh"
sdk list java
sdk install java 21.0.1-oracle
sdk use java 21.0.1-oracle
sdk default java 21.0.1-oracle

sudo chown -R $USER_NAME:$USER_NAME $SDKMAN_DIR
tee /home/$USER_NAME/.bashrc >/dev/null <<EOF
#
#
# Start: sdkman configuration
#
export SDKMAN_DIR=/app/sdkman
source "\$SDKMAN_DIR/bin/sdkman-init.sh"
#
# End: sdkman configuration
#
#
EOF
source /home/$USER_NAME/.bashrc



# [x] Create user ssh keys
ssh-keygen -P "" -q -m PEM -t rsa -b 4096 -C "USER_NAME@code-server" -N '' -f /home/$USER_NAME/.ssh/id_rsa <<<y >/dev/null 2>&1


################################################
#### cleaning up
echo "**** clean up ****"
sudo rm -rf /config/* /tmp/* /var/lib/apt/lists/* /var/tmp/*
sudo apt-get -y clean
sudo apt-get -y autoclean 
sudo apt-get -y autoremove
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /home/$USER_NAME/.env
