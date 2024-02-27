#!/bin/sh


#### Step 1 Configuring the postgresql database

## ------------------------------------------------------------------------
# [x] Configure auto system update and backup

sudo touch /etc/bluewave/update.test
sudo touch /etc/bluewave/backup.test
sudo touch /etc/bluewave/rclone.test
cat <<EOF > /etc/bluewave/backup.list
configs /etc
root /root
odoo17 /opt/odoo17
logs /var/log
EOF

# [x] Update Repository
sudo apt update

# [x] Install Odoo Dependencies
sudo apt install -y build-essential wget python3-dev python3-venv python3-wheel libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev

# [x] Install wkhtmltopdf
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo apt install --no-install-recommends ./wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo rm -rf wkhtmltox_0.12.6.1-2.jammy_amd64.deb

# [x] Install and Configure Odoo

sudo mkdir -p /opt/odoo17/odoo
sudo chown -R odoo:odoo /opt/odoo17
git clone https://www.github.com/odoo/odoo --depth 1 --branch 17.0 /opt/odoo17/odoo
cd /opt/odoo17
python3 -m venv odoo-venv
source odoo-venv/bin/activate
pip3 install wheel
pip3 install -r odoo/requirements.txt
deactivate
mkdir /opt/odoo17/odoo/odoo-custom-addons

sudo pass generate system/odoo/admin 100 -n
sudo pass insert system/odoo/postgres  # << PUT PASSWORD FROM POSTGRES VM >>

export ODOO_ADMIN_PASSWORD=$(sudo pass system/odoo/admin)
export ODOO_POSTGRES_PASSWORD=$(sudo pass system/odoo/postgres)
sudo mkdir -p /var/log/odoo/
sudo chown -R odoo:odoo /var/log/odoo/
sudo bash -c 'ODOO_ADMIN_PASSWORD=$(sudo pass system/odoo/admin) && \
              ODOO_POSTGRES_PASSWORD=$(sudo pass system/odoo/postgres) && \
cat <<EOF > /etc/odoo.conf
[options]
; Database operations password:
admin_passwd = $ODOO_ADMIN_PASSWORD
db_host = 192.168.20.2
db_port = 5432
db_user = odoo
db_password = $ODOO_POSTGRES_PASSWORD
dbfilter = ^odoo.*$
data_dir=/opt/odoo17/odoo_data
addons_path = /opt/odoo17/odoo/addons,/opt/odoo17/odoo/odoo-custom-addons
logfile = /var/log/odoo/odoo-server.log
log_level  = debug

limit_memory_hard = 2684354560
limit_memory_soft = 2147483648
limit_request = 8192
limit_time_cpu = 600
limit_time_real = 1200
max_cron_threads = 1
workers = 4


EOF'

sudo bash -c 'cat <<EOF > /etc/systemd/system/odoo.service
[Unit]
Description=Odoo

[Service]
Type=simple
SyslogIdentifier=odoo
PermissionsStartOnly=true
User=odoo
Group=odoo
ExecStart=/opt/odoo17/odoo-venv/bin/python3 /opt/odoo17/odoo/odoo-bin -c /etc/odoo.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF'

# execute the following command to initialize the database
/opt/odoo17/odoo-venv/bin/python3 /opt/odoo17/odoo/odoo-bin -c /etc/odoo.conf -i base -d odoo
# Notice: the odoo postgres user should has createdb right : ALTER USER odoo CREATEDB CREATEROLE LOGIN;
sudo systemctl daemon-reload

# [x] Start and Test Odoo
sudo systemctl enable --now odoo
sudo systemctl status odoo
sudo systemctl restart odoo
sudo journalctl -u odoo

# [x] Configure the firewall for nextcloud access
sudo ufw allow 8069/tcp



























