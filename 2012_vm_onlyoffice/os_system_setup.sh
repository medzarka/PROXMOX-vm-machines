#!/bin/bash

# [x] Update the system
echo ""
echo "---------------------------------------------------------------"
echo "Update the system"
echo ""
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y 

# [x] Create a swap file
echo ""
echo "---------------------------------------------------------------"
echo "Create a swap file"
echo ""
if test -f /swapfile; then
echo "The swap file already exists."
else
sudo fallocate -l 4G /swapfile
ls -lh /swapfile
sudo chmod 600 /swapfile
ls -lh /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo "The swap file is created."
fi
sudo tee /etc/sysctl.d/swapping >/dev/null <<EOF
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF
sudo sysctl -p /etc/sysctl.d/swapping

# [x] Install Onlyoffice Workspace
echo ""
echo "---------------------------------------------------------------"
echo "Install OnlyOffice Workspace (it could take about 20 minutes)"
echo ""
wget https://download.onlyoffice.com/install/install-Debian.sh
sudo bash install-Debian.sh -it WORKSPACE # Install ONLYOFFICE Workspace using DEB packages
sudo bash install-Debian.sh -h # to display available script parameters
#sudo bash install-Debian.sh -u true -it WORKSPACE # to update existing ONLYOFFICE Workspace components using DEB packages

# [x] Install sone fonts
echo ""
echo "---------------------------------------------------------------"
echo "Install OnlyOffice Fonts"
echo ""
sudo apt install -y build-essential libcurl4 libxml2 fonts-dejavu \
    fonts-liberation ttf-mscorefonts-installer fonts-crosextra-carlito \
    fonts-takao-gothic fonts-opensymbol fonts-hosny-amiri  \
    fonts-cmu


wget https://archive.org/download/PowerPointViewer_201801/PowerPointViewer.exe
sudo cabextract PowerPointViewer.exe -F ppviewer.cab
sudo mkdir -p /usr/share/fonts/ms
sudo cabextract ppviewer.cab -F '*.TTC' -d /usr/share/fonts/ms
sudo cabextract ppviewer.cab -F '*.TTF' -d /usr/share/fonts/ms
sudo rm -f PowerPointViewer.exe
sudo rm -f ppviewer.cab
sudo fc-cache -fv



wget https://filedn.com/luEnu9wIDvzholR0Mi4tGLb/linux_images/myfonts.zip
sudo unzip myfonts.zip
sudo mkdir -p /usr/share/fonts/myfonts
sudo cp fonts/** /usr/share/fonts/myfonts
sudo rm -rf myfonts.zip
sudo rm -rf fonts/
sudo fc-cache -fv



#wget https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip
#sudo mkdir -p /usr/share/fonts/fira
#sudo unzip Fira_Code_v6.2.zip -d /usr/share/fonts/fira
#sudo rm -rf Fira_Code_v6.2.zip
#sudo fc-cache -fv


#wget https://codeload.github.com/aisgbnok/Apple-Fonts/zip/refs/heads/main -O macos-fonts.zip
#sudo mkdir -p /usr/share/fonts/macos
#sudo unzip macos-fonts.zip -d /usr/share/fonts/macos
#sudo rm -rf macos-fonts.zip
#sudo fc-cache -fv
#sudo find /usr/share/fonts/macos -type f  -name '*.md' -delete
#sudo find /usr/share/fonts/macos -type f  -name '*.pdf' -delete
#sudo find /usr/share/fonts/macos -type f  -name '*.otf' -delete

sudo /usr/bin/documentserver-generate-allfonts.sh

# [x] Configure the firewall for onlyoffice access
echo ""
echo "---------------------------------------------------------------"
echo "Configure the firewall to open http and https ports"
echo ""
sudo ufw allow http
sudo ufw allow https

# [x] Install Remarks
echo ""
echo "---------------------------------------------------------------"
echo "The Install is done. "
echo ""
echo "Notices: "
echo "  # After installing new fonts, execute the [sudo /usr/bin/documentserver-generate-allfonts.sh]"
echo "       The, clear the cache of the browser."
echo ""
echo "  # When a new version of the Onlyoffice Workplace is available, type [sudo bash install-Debian.sh -u true -it WORKSPACE] to update."
echo ""
echo "  # When When dealing with Onedrive third-party storage, the error [he Supported account types are not set for the personal account] " could raise.
echo "       To solve this issue, navigate to the Manifest of your App registration, set the two properties accessTokenAcceptedVersion and signInAudience like below."
echo "       - \"accessTokenAcceptedVersion\": 2,"
echo "       - \"signInAudience": "AzureADandPersonalMicrosoftAccount\": 2,"
echo "       When you save the setting, make sure your app meets the requirement of the validation, otherwise there will be some errors."
echo ""
echo "---------------------------------------------------------------"
echo ""


# TODO install megacmd and mount webdav folders.
#wget https://mega.nz/linux/repo/Debian_12/amd64/megacmd-Debian_12_amd64.deb 
#&& sudo apt install "$PWD/megacmd-Debian_12_amd64.deb"


















