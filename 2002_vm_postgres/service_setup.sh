#!/bin/sh


## ------------------------------------------------------------------------
# [x] Configure auto system update and backup

touch /etc/bluewave/update.test
touch /etc/bluewave/backup.test
touch /etc/bluewave/rclone.test
cat <<EOF > /etc/bluewave/backup.list
configs /etc
postgres /var/lib/postgresql
root /root
EOF

# [x] Install and configure Postgres
apk add postgresql16
rc-update add postgresql
pg_versions set-default 16
rc-service postgresql start
rc-service postgresql status

echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/16/data/pg_hba.conf
echo "listen_addresses='*'" >> /var/lib/postgresql/16/data/postgresql.conf

pass generate system/postgres 100 -n
POSTGRES_PASS=`pass system/postgres` 
psql -U postgres
--> ALTER USER postgres WITH ENCRYPTED PASSWORD '${POSTGRES_PASS}';
--> CREATE DATABASE test;
--> \q

rc-service postgresql restart


# [x] Configure the firewall for postgres access

ufw allow  5432  

# [x] Create databases and users/roles


# [x] --- Create the nextcloud database
pass generate system/postgres/nextcloud 50 -n  
PASSWORD=`pass system/postgres/nextcloud` 
psql -U postgres
-->  CREATE DATABASE nextcloud;
-->  CREATE USER nextcloud WITH ENCRYPTED PASSWORD 'PASSWORD'; 
-->  GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud;
-->  GRANT ALL ON SCHEMA public TO nextcloud;
-->  ALTER DATABASE nextcloud OWNER TO nextcloud;
--> \q

# [x] --- Create the odoo database
pass generate system/postgres/odoo 50 -n  
PASSWORD=`pass system/postgres/odoo` 
psql -U postgres
-->  CREATE DATABASE odoo;
-->  CREATE USER odoo WITH ENCRYPTED PASSWORD 'PASSWORD'; 
-->  GRANT ALL PRIVILEGES ON DATABASE odoo TO odoo;
-->  GRANT ALL ON SCHEMA public TO odoo;
-->  ALTER DATABASE odoo OWNER TO odoo;
-->  ALTER USER odoo CREATEDB CREATEROLE LOGIN;
--> \q


# [x] --- Create the ukku2 database
pass generate system/postgres/ukku2 50 -n  
PASSWORD=`pass system/postgres/ukku2` 
psql -U postgres
-->  CREATE DATABASE ukku2;
-->  CREATE USER ukku2 WITH ENCRYPTED PASSWORD 'PASSWORD'; 
-->  GRANT ALL PRIVILEGES ON DATABASE ukku2 TO ukku2;
-->  GRANT ALL ON SCHEMA public TO ukku2;
-->  ALTER DATABASE ukku2 OWNER TO ukku2;
--> \q


# [x] --- Create the onlyoffice database
pass generate system/postgres/onlyoffice 50 -n  
PASSWORD=`pass system/postgres/onlyoffice` 
psql -U postgres
-->  CREATE DATABASE onlyoffice;
-->  CREATE USER onlyoffice WITH ENCRYPTED PASSWORD 'PASSWORD'; 
-->  GRANT ALL PRIVILEGES ON DATABASE onlyoffice TO onlyoffice;
-->  GRANT ALL ON SCHEMA public TO onlyoffice;
-->  ALTER DATABASE onlyoffice OWNER TO onlyoffice;
--> \q


reboot

