#!/bin/sh


## ------------------------------------------------------------------------
# [x] Configure auto system update and backup

touch /etc/bluewave/update.test
#touch /etc/bluewave/backup.test
#touch /etc/bluewave/rclone.test
#cat <<EOF > /etc/bluewave/backup.list
#configs /etc
#postgres /var/lib/postgresql
#EOF

# [x] Install and cloudflare client
apk add curl
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/bin/cloudflared
chmod +x /usr/bin/cloudflared

cloudflared service uninstall
pass insert system/cloudflared/token  # << PUT-HERE-THE--KEY from cloudflare website>>
CLOUDFLARED_TOKEN=$(pass system/cloudflared/token)
cloudflared service install $CLOUDFLARED_TOKEN
cat <<EOF > /etc/init.d/cloudflared
#!/sbin/openrc-run
name=\$(basename \$(readlink -f \$0))
cfgfile="/etc/\$RC_SVCNAME/\$RC_SVCNAME.conf"
command="/usr/bin/cloudflared"
command_args="--pidfile /var/run/\$name.pid  --autoupdate-freq 24h0m0s tunnel run --token $CLOUDFLARED_TOKEN"
command_user="root"
pidfile="/var/run/\$name.pid"
stdout_log="/var/log/\$name.log"
stderr_log="/var/log/\$name.err"
command_background="yes"
EOF

rc-update add cloudflared
rc-service cloudflared restart

# [x] Install and Tailscale client
curl -fsSL https://tailscale.com/install.sh | sh
rc-update add tailscale
rc-service tailscale start
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf

tailscale up --advertise-exit-node
# a link will be displayed to avtivate the machine on the tailscale network.

ip a

##################
reboot

