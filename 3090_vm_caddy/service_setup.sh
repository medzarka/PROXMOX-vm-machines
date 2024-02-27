#!/bin/sh

## ------------------------------------------------------------------------
# [x] Configure auto system update and backup

touch /etc/bluewave/update.test
touch /etc/bluewave/backup.test
touch /etc/bluewave/rclone.test
cat <<EOF > /etc/bluewave/backup.list
configs /etc
EOF

# TODO chech the update and backup algorithm


# [ ] Install and configure Caddy
apk update
apk add caddy
rc-update add caddy default
rc-service caddy status
cat << EOF > /etc/caddy/Caddyfile
# The Caddyfile is an easy way to configure your Caddy web server.
#
# Unless the file starts with a global options block, the first
# uncommented line is always the address of your site.
#
# To use your own domain name (with automatic HTTPS), first make
# sure your domain's A/AAAA DNS records are properly pointed to
# this machine's public IP, then replace ":80" below with your
# domain name.

:80 {
        # Set this path to your site's directory.
        root * /usr/share/caddy

        # Enable the static file server.
        file_server

        # Another common task is to set up a reverse proxy:
        # reverse_proxy localhost:8080

        # Or serve a PHP site through php-fpm:
        # php_fastcgi localhost:9000
}

# Refer to the Caddy docs for more information:
# https://caddyserver.com/docs/caddyfile


## PVE01
pve01.bluewave.dedyn.io {
    reverse_proxy * {
        to 192.168.10.254:8006

        lb_policy ip_hash     # Makes backend sticky based on client ip
        lb_try_duration 1s
        lb_try_interval 250ms

        health_uri /          # Backend health check path
        # health_port 80      # Default same as backend port
        health_interval 10s
        health_timeout 2s
        health_status 200

        transport http {
            tls_insecure_skip_verify
        }
    }

    #log {
    #    output file /var/log/caddy/pve01.bluewave.dedyn.io.log {
    #        roll_size 5mb
    #        roll_keep 10
    #        roll_keep_for 720h
    #  }
    #}
}

# openwrt
gw2.bluewave.dedyn.io {
    reverse_proxy * {
        to 192.168.30.1:443

        lb_policy ip_hash     # Makes backend sticky based on client ip
        lb_try_duration 1s
        lb_try_interval 250ms

        health_uri /          # Backend health check path
        # health_port 80      # Default same as backend port
        health_interval 10s
        health_timeout 2s
        health_status 200

        transport http {
            tls_insecure_skip_verify
        }
    }
}

# vscode
dev.bluewave.dedyn.io {
	reverse_proxy 192.168.30.3:8080

    #log {
    #    output file /var/log/caddy/code.bluewave.dedyn.io.log {
    #        roll_size 5mb
    #        roll_keep 10
    #        roll_keep_for 720h
    #  }
    #}
}
EOF

rc-service caddy restart


# [x] Allow access to caddy (firewall)
ufw allow http
ufw allow https


