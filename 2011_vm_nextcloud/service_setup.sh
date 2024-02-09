#!/bin/sh


#### Step 1 Configuring the postgresql database

## ------------------------------------------------------------------------
# [x] Configure auto system update and backup

touch /etc/bluewave/update.test
touch /etc/bluewave/backup.test
touch /etc/bluewave/rclone.test
cat <<EOF > /etc/bluewave/backup.list
configs /etc
root /root
nextcloud /var/lib/nextcloud/data
logs /var/log
EOF

# [x] Install and configure nextcloud
apk update
apk add nextcloud-pgsql postgresql-client
apk add nextcloud-initscript
apk add nginx php82-fpm
apk add openssl
apk add nextcloud-files_pdfviewer nextcloud-text nextcloud-notifications nextcloud-files_videoplayer nextcloud-files_external
apk add nextcloud-default-apps



#### Step 3 Configurations
rm /etc/nginx/http.d/default.conf
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl1.1/certs/nextcloud-selfsigned.key -out /etc/ssl1.1/certs/nextcloud-selfsigned.crt
cat << EOF > /etc/nginx/http.d/nextcloud.conf
server {
        listen       80;
	return 301 https://\$host$request_uri;
	server_name nextcloud.bluewave.one;
}

server {
        listen       443 ssl;
        server_name  nextcloud.bluewave.one;

	root /usr/share/webapps/nextcloud;
        index  index.php index.html index.htm;
	disable_symlinks off;

        ssl_certificate      /etc/ssl1.1/certs/nextcloud-selfsigned.crt;
        ssl_certificate_key  /etc/ssl1.1/certs/nextcloud-selfsigned.key;
        ssl_session_timeout  5m;

        #Enable Perfect Forward Secrecy and ciphers without known vulnerabilities
        #Beware! It breaks compatibility with older OS and browsers (e.g. Windows XP, Android 2.x, etc.)
	ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA;
        ssl_prefer_server_ciphers  on;


        location / {
            try_files \$uri \$uri/ /index.html;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        location ~ [^/]\.php(/|$) {
                fastcgi_split_path_info ^(.+?\.php)(/.*)$;
                if (!-f \$document_root\$fastcgi_script_name) {
                        return 404;
                }
                #fastcgi_pass 127.0.0.1:9000;
		#fastcgi_pass unix:/run/php-fpm/socket;
		fastcgi_pass unix:/run/nextcloud/fastcgi.sock; # From the nextcloud-initscript package
                fastcgi_index index.php;
                include fastcgi.conf;
	}

        # Help pass nextcloud's configuration checks after install:
        # Per https://docs.nextcloud.com/server/22/admin_manual/issues/general_troubleshooting.html#service-discovery
        location ^~ /.well-known/carddav { return 301 /remote.php/dav/; }
        location ^~ /.well-known/caldav { return 301 /remote.php/dav/; }
        location ^~ /.well-known/webfinger { return 301 /index.php/.well-known/webfinger; }
        location ^~ /.well-known/nodeinfo { return 301 /index.php/.well-known/nodeinfo; }
}
EOF


sed -r -i 's/client_max_body_size.*/client_max_body_size 0;/g' /etc/nginx/nginx.conf
sed -r -i 's/memory_limit.*/php_admin_value[memory_limit]=1024M/g' /etc/php82/php-fpm.d/nextcloud.conf
sed -r -i 's/post_max_size.*/php_admin_value[post_max_size]=1024M/g' /etc/php82/php-fpm.d/nextcloud.conf
sed -r -i 's/upload_max_filesize.*/php_admin_value[upload_max_filesize]=1024M/g' /etc/php82/php-fpm.d/nextcloud.conf
sed -r -i 's/upload_max_filesize.*/upload_max_filesize=1024M/g' /etc/php82/php.ini

#Start services:
service nginx restart
service nextcloud restart
#Enable automatic startup of services:
rc-update add nginx
rc-update add nextcloud




# [x] Configure the firewall for nextcloud access
ufw allow http
ufw allow https

# [x] Generate the admin user and install nextcloud
pass generate system/nextcloud/admin 100 -n

# then access to the webpage and complete the install instructions



























