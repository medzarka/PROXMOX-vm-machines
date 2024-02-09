#!/bin/sh

##### Common section: read the password and extract rootfs files
ROOT_PASS=`cat /root/secret`
rm -f /root/secret
tar -xzvf /root/rootfs.tar.gz -C /
#rm -rf /root/rootfs.tar.gz

# see https://openwrt.org/docs/guide-user/base-system/uci

################################################################ tested ok
echo '\n 1 - System configurations:'
uci set system.@system[0]=system
uci set system.@system[0].hostname='openwrt'
uci set system.@system[0].ttylogin='1'
uci set system.@system[0].log_size='128'
uci set system.@system[0].urandom_seed='0'
uci set system.@system[0].zonename='Asia/Riyadh'
uci set system.@system[0].log_proto='udp'
uci set system.@system[0].conloglevel='8'
uci set system.@system[0].cronloglevel='5'
uci set system.@system[0].description='openwrt.bluewave.pve01.lan'
uci set system.@system[0].timezone='<+03>-3'
uci set system.ntp=timeserver
uci set system.ntp.enable_server='1'
uci delete system.ntp.server > /dev/null 2>&1
uci add_list system.ntp.server='0.de.pool.ntp.org'
uci add_list system.ntp.server='1.de.pool.ntp.org'
uci add_list system.ntp.server='2.de.pool.ntp.org'

uci commit 
reload_config

################################################################ tested ok
echo ' 2 - SSH access configurations:'
uci set dropbear.@dropbear[0]=dropbear
uci set dropbear.@dropbear[0].PasswordAuth='on'
uci set dropbear.@dropbear[0].Port='22'
uci set dropbear.@dropbear[0].GatewayPorts='on'

uci commit 
reload_config

################################################################ tested ok
echo ' 3 - Luci configurations:'
uci set luci.main=core
uci set luci.main.lang='auto'
uci set luci.main.mediaurlbase='/luci-static/bootstrap-dark'
uci set luci.main.resourcebase='/luci-static/resources'
uci set luci.main.ubuspath='/ubus/'
uci set luci.flash_keep=extern
uci set luci.flash_keep.uci='/etc/config/'
uci set luci.flash_keep.dropbear='/etc/dropbear/'
uci set luci.flash_keep.openvpn='/etc/openvpn/'
uci set luci.flash_keep.passwd='/etc/passwd'
uci set luci.flash_keep.opkg='/etc/opkg.conf'
uci set luci.flash_keep.firewall='/etc/firewall.user'
uci set luci.flash_keep.uploads='/lib/uci/upload/'
uci set luci.languages=internal
uci set luci.sauth=internal
uci set luci.sauth.sessionpath='/tmp/luci-sessions'
uci set luci.sauth.sessiontime='3600'
uci set luci.ccache=internal
uci set luci.ccache.enable='1'
uci set luci.themes=internal
uci set luci.themes.Bootstrap='/luci-static/bootstrap'
uci set luci.themes.BootstrapDark='/luci-static/bootstrap-dark'
uci set luci.themes.BootstrapLight='/luci-static/bootstrap-light'
uci set luci.apply=internal
uci set luci.apply.rollback='90'
uci set luci.apply.holdoff='4'
uci set luci.apply.timeout='5'
uci set luci.apply.display='1.5'
uci set luci.diag=internal
uci set luci.diag.dns='openwrt.org'
uci set luci.diag.ping='openwrt.org'
uci set luci.diag.route='openwrt.org'

uci commit 
reload_config

################################################################ tested ok
echo ' 4 - RPCD configurations:'
uci set rpcd.@rpcd[0]=rpcd
uci set rpcd.@rpcd[0].socket='/var/run/ubus/ubus.sock'
uci set rpcd.@rpcd[0].timeout='30'
uci set rpcd.@login[0]=login
uci set rpcd.@login[0].username='root'
uci set rpcd.@login[0].password='$p$root'
uci set rpcd.@login[0].read='*'
uci set rpcd.@login[0].write='*'

uci commit 
reload_config

################################################################ tested ok
echo ' 5 - UCI TRACK configurations:'
uci set ucitrack.@network[0]=network
uci set ucitrack.@network[0].init='network'
uci set ucitrack.@network[0].affects='dhcp'
uci set ucitrack.@wireless[0]=wireless
uci set ucitrack.@wireless[0].affects='network'
uci set ucitrack.@firewall[0]=firewall
uci set ucitrack.@firewall[0].init='firewall'
uci delete ucitrack.@firewall[0].affects > /dev/null 2>&1
uci add_list ucitrack.@firewall[0].affects='luci-splash'
uci add_list ucitrack.@firewall[0].affects='qos'
uci add_list ucitrack.@firewall[0].affects='miniupnpd'
#uci set ucitrack.@firewall[0].affects= 'qos' 'miniupnpd'
uci set ucitrack.@olsr[0]=olsr
uci set ucitrack.@olsr[0].init='olsrd'
uci set ucitrack.@dhcp[0]=dhcp
uci set ucitrack.@dhcp[0].init='dnsmasq'
uci set ucitrack.@dhcp[0].affects='odhcpd'
uci set ucitrack.@odhcpd[0]=odhcpd
uci set ucitrack.@odhcpd[0].init='odhcpd'
uci set ucitrack.@dropbear[0]=dropbear
uci set ucitrack.@dropbear[0].init='dropbear'
uci set ucitrack.@httpd[0]=httpd
uci set ucitrack.@httpd[0].init='httpd'
uci set ucitrack.@fstab[0]=fstab
uci set ucitrack.@fstab[0].exec='/sbin/block mount'
uci set ucitrack.@qos[0]=qos
uci set ucitrack.@qos[0].init='qos'
uci set ucitrack.@system[0]=system
uci set ucitrack.@system[0].init='led'
uci set ucitrack.@system[0].exec='/etc/init.d/log reload'
uci delete ucitrack.@system[0].affects > /dev/null 2>&1
uci add_list ucitrack.@system[0].affects='luci_statistics'
uci add_list ucitrack.@system[0].affects='dhcp'
#uci set ucitrack.@system[0].affects='luci_statistics' 'dhcp'
uci set ucitrack.@luci_splash[0]=luci_splash
uci set ucitrack.@luci_splash[0].init='luci_splash'
uci set ucitrack.@upnpd[0]=upnpd
uci set ucitrack.@upnpd[0].init='miniupnpd'
uci set ucitrack.@ntpclient[0]=ntpclient
uci set ucitrack.@ntpclient[0].init='ntpclient'
uci set ucitrack.@samba[0]=samba
uci set ucitrack.@samba[0].init='samba'
uci set ucitrack.@tinyproxy[0]=tinyproxy
uci set ucitrack.@tinyproxy[0].init='tinyproxy'

uci commit 
reload_config

################################################################ tested ok
echo ' 6 - uHTTPd configurations:'
uci set uhttpd.main=uhttpd
uci delete uhttpd.main.listen_http > /dev/null 2>&1
uci add_list uhttpd.main.listen_http='0.0.0.0:80'
uci add_list uhttpd.main.listen_http='[::]:80'
#uci set uhttpd.main.listen_http='0.0.0.0:80' '[::]:80'

uci delete uhttpd.main.listen_https > /dev/null 2>&1
uci add_list uhttpd.main.listen_https='0.0.0.0:443'
uci add_list uhttpd.main.listen_https='[::]:443'
#uci set uhttpd.main.listen_https='0.0.0.0:443' '[::]:443'

uci set uhttpd.main.redirect_https='1'
uci set uhttpd.main.home='/www'
uci set uhttpd.main.rfc1918_filter='1'
uci set uhttpd.main.max_requests='3'
uci set uhttpd.main.max_connections='100'
uci set uhttpd.main.cert='/etc/uhttpd.crt'
uci set uhttpd.main.key='/etc/uhttpd.key'
uci set uhttpd.main.cgi_prefix='/cgi-bin'
uci set uhttpd.main.lua_prefix='/cgi-bin/luci=/usr/lib/lua/luci/sgi/uhttpd.lua'
uci set uhttpd.main.script_timeout='60'
uci set uhttpd.main.network_timeout='30'
uci set uhttpd.main.http_keepalive='20'
uci set uhttpd.main.tcp_keepalive='1'
uci set uhttpd.main.ubus_prefix='/ubus'
uci set uhttpd.defaults=cert
uci set uhttpd.defaults.days='730'
uci set uhttpd.defaults.key_type='ec'
uci set uhttpd.defaults.bits='2048'
uci set uhttpd.defaults.ec_curve='P-256'
uci set uhttpd.defaults.country='ZZ'
uci set uhttpd.defaults.state='Somewhere'
uci set uhttpd.defaults.location='Unknown'
uci set uhttpd.defaults.commonname='OpenWrt'


uci commit 
reload_config

################################################################ tested ok
echo ' 7 - Network configurations:'
uci set network.loopback=interface
uci set network.loopback.proto='static'
uci set network.loopback.ipaddr='127.0.0.1'
uci set network.loopback.netmask='255.0.0.0'
uci set network.loopback.device='lo'

#uci set network.wan6=interface
#uci set network.wan6.proto='dhcpv6'
#uci set network.wan6.device='eth0'

uci set network.wan=interface
uci set network.wan.ipaddr='45.141.36.210'
uci set network.wan.gateway='45.141.36.1'
uci set network.wan.netmask='255.255.255.0'
uci set network.wan.dns='193.110.81.9'
uci set network.wan.proto='static'
uci set network.wan.device='eth0'

#uci set network.@device[0]=device
uci add network device
uci set network.@device[-1].type='8021q'
uci set network.@device[-1].ifname='eth1'
uci set network.@device[-1].vid='10'
uci set network.@device[-1].name='eth1.10'
uci set network.@device[-1].ipv6='0'

#uci set network.@device[0]=device
uci add network device
uci set network.@device[-1].type='8021q'
uci set network.@device[-1].ifname='eth1'
uci set network.@device[-1].vid='20'
uci set network.@device[-1].name='eth1.20'
uci set network.@device[-1].ipv6='0'

#uci set network.@device[0]=device
uci add network device
uci set network.@device[-1].type='8021q'
uci set network.@device[-1].ifname='eth1'
uci set network.@device[-1].vid='30'
uci set network.@device[-1].name='eth1.30'
uci set network.@device[-1].ipv6='0'

#uci set network.@device[0]=device
uci add network device
uci set network.@device[-1].type='8021q'
uci set network.@device[-1].ifname='eth1'
uci set network.@device[-1].vid='40'
uci set network.@device[-1].name='eth1.40'
uci set network.@device[-1].ipv6='0'

uci set network.LAN_HOST=interface
uci set network.LAN_HOST.proto='static'
uci set network.LAN_HOST.device='eth1.10'
uci set network.LAN_HOST.ipaddr='192.168.10.1'
uci set network.LAN_HOST.netmask='255.255.255.0'

uci set network.DMZ=interface
uci set network.DMZ.proto='static'
uci set network.DMZ.device='eth1.20'
uci set network.DMZ.ipaddr='192.168.20.1'
uci set network.DMZ.netmask='255.255.255.0'

uci set network.LAN_VMs=interface
uci set network.LAN_VMs.proto='static'
uci set network.LAN_VMs.device='eth1.30'
uci set network.LAN_VMs.ipaddr='192.168.30.1'
uci set network.LAN_VMs.netmask='255.255.255.0'

uci set network.LAN_LXCs=interface
uci set network.LAN_LXCs.proto='static'
uci set network.LAN_LXCs.device='eth1.40'
uci set network.LAN_LXCs.ipaddr='192.168.40.1'
uci set network.LAN_LXCs.netmask='255.255.255.0'

uci commit 
reload_config

################################################################
echo ' 8 - Firewall configurations:'

echo '      Configuring default firewall'
uci set firewall.@defaults[0]=defaults
uci set firewall.@defaults[0].input='REJECT'
uci set firewall.@defaults[0].output='ACCEPT'
uci set firewall.@defaults[0].forward='REJECT'
uci set firewall.@defaults[0].synflood_protect='1'

echo '      Cleaning firewall'
while uci delete firewall.@zone[-1] > /dev/null 2>&1; do
echo ''  > /dev/null 2>&1
done
while uci delete firewall.@forwarding[-1] > /dev/null 2>&1; do
echo '' > /dev/null 2>&1
done
while uci delete firewall.@rule[-1] > /dev/null 2>&1; do
echo '' > /dev/null 2>&1
done

echo '      Configuring firewall zones'
#uci set firewall.@zone[-1]=zone

uci add firewall zone > /dev/null
uci set firewall.@zone[-1].name='lan'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='ACCEPT'
uci delete firewall.@zone[-1].network > /dev/null 2>&1
uci add_list firewall.@zone[-1].network='LAN_HOST'
uci add_list firewall.@zone[-1].network='LAN_LXCs'
uci add_list firewall.@zone[-1].network='LAN_VMs'
#uci set firewall.@zone[0].network='LAN_HOST' 'LAN_LXCs' 'LAN_VMs'

#uci set firewall.@zone[1]=zone
uci add firewall zone > /dev/null
uci set firewall.@zone[-1].name='wan'
uci set firewall.@zone[-1].input='DROP'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='DROP'
uci set firewall.@zone[-1].masq='1'
uci set firewall.@zone[-1].mtu_fix='1'
uci delete firewall.@zone[-1].network > /dev/null 2>&1
uci add_list firewall.@zone[-1].network='wan'
#uci add_list firewall.@zone[1].network='wan6'
#uci set firewall.@zone[1].network='wan' 'wan6'

#uci set firewall.@zone[2]=zone
uci add firewall zone > /dev/null
uci set firewall.@zone[-1].name='dmz'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].device='eth1.20'
uci set firewall.@zone[-1].family='ipv4'
uci set firewall.@zone[-1].network='DMZ'

echo '      Configuring firewall zones forwarding'
uci add firewall forwarding > /dev/null
#uci set firewall.@forwarding[0]=forwarding
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='wan'

uci add firewall forwarding > /dev/null
#uci set firewall.@forwarding[1]=forwarding
uci set firewall.@forwarding[-1].src='dmz'
uci set firewall.@forwarding[-1].dest='wan'

uci add firewall forwarding > /dev/null
#uci set firewall.@forwarding[2]=forwarding
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='dmz'

echo '      Configuring firewall rules'
uci add firewall rule > /dev/null
#uci set firewall.@rule[-1]=rule
uci set firewall.@rule[-1].name='Allow-DHCP-Renew'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].proto='udp'
uci set firewall.@rule[-1].dest_port='68'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].family='ipv4'

uci add firewall rule > /dev/null
#uci set firewall.@rule[1]=rule
uci set firewall.@rule[-1].name='Allow-Ping'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].proto='icmp'
uci set firewall.@rule[-1].icmp_type='echo-request'
uci set firewall.@rule[-1].family='ipv4'
uci set firewall.@rule[-1].target='ACCEPT'

uci add firewall rule > /dev/null
#uci set firewall.@rule[2]=rule
uci set firewall.@rule[-1].name='Allow-IGMP'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].proto='igmp'
uci set firewall.@rule[-1].family='ipv4'
uci set firewall.@rule[-1].target='ACCEPT'

uci add firewall rule > /dev/null
#uci set firewall.@rule[3]=rule
uci set firewall.@rule[-1].name='Allow-DHCPv6'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].proto='udp'
uci set firewall.@rule[-1].dest_port='546'
uci set firewall.@rule[-1].family='ipv6'
uci set firewall.@rule[-1].target='ACCEPT'

uci add firewall rule > /dev/null
#uci set firewall.@rule[4]=rule
uci set firewall.@rule[-1].name='Allow-MLD'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].proto='icmp'
uci set firewall.@rule[-1].src_ip='fe80::/10'
uci delete firewall.@rule[-1].icmp_type > /dev/null 2>&1
uci add_list firewall.@rule[-1].icmp_type='130/0'
uci add_list firewall.@rule[-1].icmp_type='131/0'
uci add_list firewall.@rule[-1].icmp_type='132/0'
uci add_list firewall.@rule[-1].icmp_type='143/0'
#uci set firewall.@rule[4].icmp_type='130/0' '131/0' '132/0' '143/0'
uci set firewall.@rule[-1].family='ipv6'
uci set firewall.@rule[-1].target='ACCEPT'

uci add firewall rule > /dev/null
#uci set firewall.@rule[5]=rule
uci set firewall.@rule[-1].name='Allow-ICMPv6-Input'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].proto='icmp'
uci delete firewall.@rule[-1].icmp_type > /dev/null 2>&1
uci add_list firewall.@rule[-1].icmp_type='echo-request'
uci add_list firewall.@rule[-1].icmp_type='echo-reply'
uci add_list firewall.@rule[-1].icmp_type='destination-unreachable'
uci add_list firewall.@rule[-1].icmp_type='packet-too-big'
uci add_list firewall.@rule[-1].icmp_type='time-exceeded'
uci add_list firewall.@rule[-1].icmp_type='bad-header'
uci add_list firewall.@rule[-1].icmp_type='unknown-header-type'
uci add_list firewall.@rule[-1].icmp_type='router-solicitation'
uci add_list firewall.@rule[-1].icmp_type='neighbour-solicitation'
uci add_list firewall.@rule[-1].icmp_type='router-advertisement'
uci add_list firewall.@rule[-1].icmp_type='neighbour-advertisement'
#uci set firewall.@rule[5].icmp_type='echo-request' 'echo-reply' 'destination-unreachable' 'packet-too-big' 'time-exceeded' 'bad-header' 'unknown-header-type' 'router-solicitation' 'neighbour-solicitation' 'router-advertisement' 'neighbour-advertisement'
uci set firewall.@rule[-1].limit='1000/sec'
uci set firewall.@rule[-1].family='ipv6'
uci set firewall.@rule[-1].target='ACCEPT'

uci add firewall rule > /dev/null
#uci set firewall.@rule[6]=rule
uci set firewall.@rule[-1].name='Allow-ICMPv6-Forward'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest='*'
uci set firewall.@rule[-1].proto='icmp'
uci delete firewall.@rule[-1].icmp_type > /dev/null 2>&1
uci add_list firewall.@rule[-1].icmp_type='echo-request'
uci add_list firewall.@rule[-1].icmp_type='echo-reply'
uci add_list firewall.@rule[-1].icmp_type='destination-unreachable'
uci add_list firewall.@rule[-1].icmp_type='packet-too-big'
uci add_list firewall.@rule[-1].icmp_type='time-exceeded'
uci add_list firewall.@rule[-1].icmp_type='bad-header'
uci add_list firewall.@rule[-1].icmp_type='unknown-header-type'
#uci set firewall.@rule[6].icmp_type='echo-request' 'echo-reply' 'destination-unreachable' 'packet-too-big' 'time-exceeded' 'bad-header' 'unknown-header-type'
uci set firewall.@rule[-1].limit='1000/sec'
uci set firewall.@rule[-1].family='ipv6'
uci set firewall.@rule[-1].target='ACCEPT'

uci add firewall rule > /dev/null
#uci set firewall.@rule[7]=rule
uci set firewall.@rule[-1].name='Allow-IPSec-ESP'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest='lan'
uci set firewall.@rule[-1].proto='esp'
uci set firewall.@rule[-1].target='ACCEPT'

uci add firewall rule > /dev/null
#uci set firewall.@rule[8]=rule
uci set firewall.@rule[-1].name='Allow-ISAKMP'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest='lan'
uci set firewall.@rule[-1].dest_port='500'
uci set firewall.@rule[-1].proto='udp'
uci set firewall.@rule[-1].target='ACCEPT'

#uci add firewall rule > /dev/null
#uci set firewall.@rule[9]=rule
#uci set firewall.@rule[-1].name='Allow-Admin'
#uci set firewall.@rule[-1].src='wan'
#uci set firewall.@rule[-1].proto='tcp'
#uci set firewall.@rule[-1].dest_port='443'
#uci set firewall.@rule[-1].target='ACCEPT'

uci commit 
reload_config


################################################################
echo ' 8 - DHCP configurations:'

uci set dhcp.@dnsmasq[0]=dnsmasq
uci set dhcp.@dnsmasq[0].domainneeded='1'
uci set dhcp.@dnsmasq[0].localise_queries='1'
uci set dhcp.@dnsmasq[0].rebind_protection='1'
uci set dhcp.@dnsmasq[0].rebind_localhost='1'
uci set dhcp.@dnsmasq[0].local='/lan/'
uci set dhcp.@dnsmasq[0].domain='bluewave.pve01.lan'
uci set dhcp.@dnsmasq[0].expandhosts='1'
uci set dhcp.@dnsmasq[0].cachesize='1000'
uci set dhcp.@dnsmasq[0].authoritative='1'
uci set dhcp.@dnsmasq[0].readethers='1'
uci set dhcp.@dnsmasq[0].leasefile='/tmp/dhcp.leases'
uci set dhcp.@dnsmasq[0].resolvfile='/tmp/resolv.conf.d/resolv.conf.auto'
uci set dhcp.@dnsmasq[0].localservice='1'
uci set dhcp.@dnsmasq[0].ednspacket_max='1232'
uci set dhcp.@dnsmasq[0].server='193.110.81.9'
uci set dhcp.wan=dhcp
uci set dhcp.wan.interface='wan'
uci set dhcp.wan.ignore='1'
uci set dhcp.odhcpd=odhcpd
uci set dhcp.odhcpd.maindhcp='0'
uci set dhcp.odhcpd.leasefile='/tmp/hosts/odhcpd'
uci set dhcp.odhcpd.leasetrigger='/usr/sbin/odhcpd-update'
uci set dhcp.odhcpd.loglevel='4'
uci set dhcp.LAN_HOST=dhcp
uci set dhcp.LAN_HOST.interface='LAN_HOST'
uci set dhcp.LAN_HOST.start='100'
uci set dhcp.LAN_HOST.limit='199'
uci set dhcp.LAN_HOST.leasetime='12h'
uci set dhcp.LAN_HOST.force='1'
uci set dhcp.DMZ=dhcp
uci set dhcp.DMZ.interface='DMZ'
uci set dhcp.DMZ.start='100'
uci set dhcp.DMZ.limit='199'
uci set dhcp.DMZ.leasetime='12h'
uci set dhcp.DMZ.force='1'
uci set dhcp.LAN_VMs=dhcp
uci set dhcp.LAN_VMs.interface='LAN_VMs'
uci set dhcp.LAN_VMs.start='100'
uci set dhcp.LAN_VMs.limit='199'
uci set dhcp.LAN_VMs.leasetime='12h'
uci set dhcp.LAN_VMs.force='1'
uci set dhcp.LAN_LXCs=dhcp
uci set dhcp.LAN_LXCs.interface='LAN_LXCs'
uci set dhcp.LAN_LXCs.start='100'
uci set dhcp.LAN_LXCs.limit='199'
uci set dhcp.LAN_LXCs.leasetime='12h'
uci set dhcp.LAN_LXCs.force='1'

uci commit 
reload_config

################################################################
echo ' 9 - Update the packages:'
opkg update
#opkg list-upgradable| awk '{print $1}'| tr '\n' ' '| xargs -r opkg upgrade

################################################################
echo ' 10 - Install needed packages:'
opkg install nano-full htop luci-ssl
# bcp38 banip 

#/etc/init.d/uhttpd disable
