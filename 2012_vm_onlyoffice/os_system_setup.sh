#!/bin/sh


# [x] Update the system
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y 

# [x] Install Onlyoffice Workspace
wget https://download.onlyoffice.com/install/workspace-install.sh




wget https://download.onlyoffice.com/install/workspace-install.sh
sudo bash workspace-install.sh

docker exec 9214615ec0a9 sudo documentserver-jwt-status.sh



# [x] Install Required Dependencies
sudo apt install -y build-essential libcurl4 libxml2 fonts-dejavu fonts-liberation ttf-mscorefonts-installer fonts-crosextra-carlito fonts-takao-gothic fonts-opensymbol 


# [ ] Install onlyoffice doc server
echo onlyoffice-documentserver onlyoffice/ds-port select 80 | sudo debconf-set-selections
#Set PostgreSQL database host address (replacing <DB_HOST> with the actual address of the PostgreSQL server installed):
echo onlyoffice-documentserver onlyoffice/db-host string 192.168.20.2 | sudo debconf-set-selections
#Set PostgreSQL database user name (replacing <DB_USER> with the actual name of the user with the appropriate PostgreSQL database rights):
echo onlyoffice-documentserver onlyoffice/db-user string onlyoffice | sudo debconf-set-selections
#Set PostgreSQL database user password (replacing <DB_PASSWORD> with the actual password of the user with the appropriate PostgreSQL database rights):
sudo pass insert system/onlyoffice/postgres
DB_PASSOWORD=$(sudo pass system/onlyoffice/postgres)
echo onlyoffice-documentserver onlyoffice/db-pwd password $DB_PASSOWORD | sudo debconf-set-selections
#Set PostgreSQL database name (replacing <DB_NAME> with the actual PostgreSQL database name):
echo onlyoffice-documentserver onlyoffice/db-name string onlyoffice | sudo debconf-set-selections

echo onlyoffice-documentserver onlyoffice/jwt-enabled boolean true | sudo debconf-set-selections
sudo pass generate system/onlyoffice/jwt 30 -n
JWT_PASSOWORD=$(sudo pass system/onlyoffice/jwt)
echo onlyoffice-documentserver onlyoffice/jwt-secret password $JWT_PASSOWORD | sudo debconf-set-selections

# TODO https://www.onlyoffice.com/groups.aspx?utm_source=test_example&utm_medium=start_screen&utm_campaign=installation

mkdir -p -m 700 ~/.gnupg
curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --import
chmod 644 /tmp/onlyoffice.gpg
sudo chown root:root /tmp/onlyoffice.gpg
sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg
echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" | sudo tee /etc/apt/sources.list.d/onlyoffice.list
sudo apt-get update
sudo apt-get install onlyoffice-documentserver



## SSL configuration
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096

sudo service nginx stop
sudo cp /etc/onlyoffice/documentserver/nginx/ds.conf /etc/onlyoffice/documentserver/nginx/ds.conf.old
sudo cp -f /etc/onlyoffice/documentserver/nginx/ds-ssl.conf.tmpl /etc/onlyoffice/documentserver/nginx/ds.conf
#--> {{SSL_CERTIFICATE_PATH}}  --> /etc/ssl/certs/nginx-selfsigned.crt
#--> {{SSL_KEY_PATH}} --> /etc/ssl/private/nginx-selfsigned.key
sudo service nginx start
sudo bash /usr/bin/documentserver-update-securelink.sh

sudo cp /etc/onlyoffice/documentserver/local.json /etc/onlyoffice/documentserver/local.json.old
sudo systemctl restart ds-*




# [x] Configure the firewall for onlyoffice access
sudo ufw allow http
sudo ufw allow https



###################################
The error means the Supported account types are not set for the personal account(Microsoft account in your case).

To solve the issue, navigate to the Manifest of your App registration, set the two properties accessTokenAcceptedVersion and signInAudience like below.

"accessTokenAcceptedVersion": 2,
"signInAudience": "AzureADandPersonalMicrosoftAccount"
When you save the setting, make sure your app meets the requirement of the validation, otherwise there will be some errors.

























