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
sudo apt-get install unzip -y 



# [x] Install PHP and PHP extensions for Moodle
echo ""
echo "---------------------------------------------------------------"
echo "Install PHP and PHP extensions for Moodle"
echo ""
sudo apt install php8.2 php8.2-{fpm,common,mbstring,xmlrpc,soap,gd,xml,intl,mysql,cli,mcrypt,ldap,zip,curl} -y

php -v

sudo sed -i 's/?memory_limit = 128M/memory_limit = 256M/g' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 80M/g' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 360/g' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/;max_input_vars = 1000/max_input_vars=5000/g' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 80M/g' /etc/php/8.2/fpm/php.ini
sudo service php8.2-fpm restart


# [x] Install mariadb and create a database
echo ""
echo "---------------------------------------------------------------"
echo "Install mariadb"
echo ""
sudo apt install mariadb-server mariadb-client -y
sudo systemctl start mariadb
sudo systemctl stop mariadb
sudo systemctl enable mariadb
sudo sed -i '/\[mysqld\]/a\\ndefault_storage_engine = innodb' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i '/\[mysqld\]/a\\ninnodb_file_per_table = 1' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i '/\[mysqld\]/a\\ninnodb_file_format = Barracuda' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb
sudo systemctl status mariadb

sudo mysql -u root -e 'DROP DATABASE moodledb'
sudo mysql -u root -e 'CREATE DATABASE moodledb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci'
sudo mysql -u root -e "CREATE USER 'moodle'@'localhost' IDENTIFIED BY 'AQWERTYUHNdzvdsfvdv'"
sudo mysql -u root -e "GRANT ALL ON moodledb.* TO 'moodle'@'localhost'"
sudo mysql -u root -e "FLUSH PRIVILEGES"
sudo mysql -u root -e "COMMIT"

# [x] Download Moodle
echo ""
echo "---------------------------------------------------------------"
echo "Download Moodle"
echo ""

sudo wget https://packaging.moodle.org/stable403/moodle-latest-403.zip
sudo unzip moodle-latest-403.zip -d /var/www/html/
sudo chown -R www-data:www-data /var/www/html/moodle/
sudo chmod -R 755 /var/www/html/moodle/
sudo rm moodle-latest-403.zip*

sudo mkdir /var/www/html/moodledata
sudo chown -R www-data:www-data /var/www/html/moodledata
sudo chmod -R 755 /var/www/html/moodledata


# [x] Install and configure nginx
echo ""
echo "---------------------------------------------------------------"
echo "Install and configure nginx"
echo ""
sudo apt install nginx-full -y

sudo openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt \
-subj "/C=SA/ST=Lima/L=Lima/O=Acme Inc. /OU=LAB/CN=acme.com"

sudo openssl dhparam -dsaparam -out /etc/nginx/dhparam.pem 4096

mkdir -p /etc/nginx/snippets

sudo tee /etc/nginx/snippets/self-signed.conf >/dev/null <<EOF
ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
EOF

sudo tee /etc/nginx/snippets/ssl-params.conf >/dev/null <<EOF
ssl_protocols TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_dhparam /etc/nginx/dhparam.pem; 
ssl_ciphers EECDH+AESGCM:EDH+AESGCM;
ssl_ecdh_curve secp384r1;
ssl_session_timeout  10m;
ssl_session_cache shared:SSL:2m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable strict transport security for now. You can uncomment the following
# line if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
EOF

sudo tee /etc/nginx/sites-available/moodle.conf >/dev/null <<EOF
server {
    listen 443 ssl;

    include snippets/self-signed.conf;
    include snippets/ssl-params.conf;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log info;

    client_max_body_size 0;

    root /var/www/html/moodle;
    index  index.php index.html index.htm;
    server_name moodle.bluewave.one;

    location / {
    try_files \$uri \$uri/ =404;        
    }

    location ~ [^/]\.php(/|$) {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
server {
    listen 80;
    return 301 https://\$server_name\$request_uri;
}
EOF
sudo ln -s /etc/nginx/sites-available/moodle.conf /etc/nginx/sites-enabled/

sudo nginx -t

sudo systemctl restart nginx
sudo systemctl enable nginx
sudo systemctl status nginx

sudo ufw allow http
sudo ufw allow https


################################################
#### cleaning up
echo "**** clean up ****"
sudo rm -rf /config/* /tmp/* /var/lib/apt/lists/* /var/tmp/*
sudo apt-get -y clean
sudo apt-get -y autoclean 
sudo apt-get -y autoremove
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /home/$USER_NAME/.env
