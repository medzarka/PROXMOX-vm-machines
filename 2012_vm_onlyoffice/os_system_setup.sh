#!/bin/sh


# [x] Update the system
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y 

# [x] Create a swap file
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
wget https://download.onlyoffice.com/install/install-Debian.sh
sudo bash install-Debian.sh -it WORKSPACE # Install ONLYOFFICE Workspace using DEB packages
sudo bash install-Debian.sh -h # to display available script parameters
sudo bash install-Debian.sh -u true -it WORKSPACE # to update existing ONLYOFFICE Workspace components using DEB packages

# [x] Install sone fonts
sudo apt install -y build-essential libcurl4 libxml2 fonts-dejavu \
    fonts-liberation ttf-mscorefonts-installer fonts-crosextra-carlito \
    fonts-takao-gothic fonts-opensymbol fonts-hosny-amiri  \
    fonts-ibm-plex fonts-droid-fallback

wget https://archive.org/download/PowerPointViewer_201801/PowerPointViewer.exe
sudo cabextract PowerPointViewer.exe -F ppviewer.cab
sudo mkdir -p /usr/share/fonts/powerpoint
sudo cabextract ppviewer.cab -F '*.TTC' -d /usr/share/fonts/ms
sudo cabextract ppviewer.cab -F '*.TTF' -d /usr/share/fonts/ms
sudo rm -f PowerPointViewer.exe
sudo rm -f ppviewer.cab
sudo fc-cache -fv

wget https://filedn.com/luEnu9wIDvzholR0Mi4tGLb/linux_images/win_fonts.zip
sudo unzip win_fonts.zip
sudo mkdir -p /usr/share/fonts/windows
sudo cp win_fonts/** /usr/share/fonts/windows
sudo rm -rf win_fonts.zip
sudo rm -rf win_fonts/
sudo fc-cache -fv




# [x] Configure the firewall for onlyoffice access
sudo ufw allow http
sudo ufw allow https



###################################
#The error means the Supported account types are not set for the personal account(Microsoft account in your case).
#
#To solve the issue, navigate to the Manifest of your App registration, set the two properties accessTokenAcceptedVersion and signInAudience like below.
#
#"accessTokenAcceptedVersion": 2,
#"signInAudience": "AzureADandPersonalMicrosoftAccount"
#When you save the setting, make sure your app meets the requirement of the validation, otherwise there will be some errors.

























