#!/bin/bash

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

# [x] Install mariadb
echo ""
echo "---------------------------------------------------------------"
echo "Install mariadb"
echo ""
sudo apt install mariadb-server mariadb-client
sudo systemctl start mariadb
sudo systemctl stop mariadb
sudo systemctl enable mariadb

sudo tee /etc/mysql/mariadb.conf.d/50-server.cnf >/dev/null <<EOF
default_storage_engine = innodb
innodb_file_per_table = 1
innodb_file_format = Barracuda
EOF
sudo systemctl restart mariadb
sudo systemctl status mariadb

# [x] Install and configure apache
echo ""
echo "---------------------------------------------------------------"
echo "Install and configure apache"
echo ""
sudo apt install apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2

# [x] Install PHP and PHP extensions for Moodle
echo ""
echo "---------------------------------------------------------------"
echo "Install PHP and PHP extensions for Moodle"
echo ""
sudo apt install php libapache2-mod-php php-iconv php-intl \
    php-soap php-zip php-curl php-mbstring php-mysql \
    php-gd php-xml php-pspell php-json php-xmlrpc
php -v

# [x] Create Database
echo ""
echo "---------------------------------------------------------------"
echo "Create Database"
echo ""

#CREATE DATABASE moodledb;
#CREATE USER 'moodle_user'@'localhost' IDENTIFIED BY 'Moodle_Passw0rd!';
#GRANT ALL ON moodledb.* TO 'moodle_user'@'localhost';
#FLUSH PRIVILEGES;
#EXIT

# [x] Download Moodle
echo ""
echo "---------------------------------------------------------------"
echo "Download Moodle"
echo ""
sudo wget https://packaging.moodle.org/stable403/moodle-latest-403.zip
sudo unzip moodle-latest-403.zip -d /var/www/html/
sudo mkdir /var/www/html/moodledata
sudo chown -R www-data:www-data /var/www/html/moodle/
sudo chmod -R 755 /var/www/html/moodle/
sudo chown -R www-data:www-data /var/www/html/moodledata/

# [x] Configure Apache Web Server for Moodle
echo ""
echo "---------------------------------------------------------------"
echo "Configure Apache Web Server for Moodle"
echo ""
sudo tee /etc/apache2/sites-available/moodle.conf >/dev/null <<EOF
<VirtualHost *:80>

ServerAdmin webmaster@moodle.bluewave.com

ServerName moodle.bluewave.com
ServerAlias moodle.bluewave.com
DocumentRoot /var/www/html/moodle

<Directory /var/www/html/moodle/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
</Directory>

ErrorLog \${APACHE_LOG_DIR}/moodle.bluewave.com_error.log
CustomLog \${APACHE_LOG_DIR}/moodle.bluewave.com_access.log combined

</VirtualHost>
EOF
sudo a2ensite moodle.conf
sudo systemctl restart apache2


################################################
#### cleaning up
echo "**** clean up ****"
sudo rm -rf /config/* /tmp/* /var/lib/apt/lists/* /var/tmp/*
sudo apt-get -y clean
sudo apt-get -y autoclean 
sudo apt-get -y autoremove
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /home/$USER_NAME/.env
