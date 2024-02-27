# openwrt.bluewave.dedyn.io

## The system

The container uses openwrt 23.05.

## Networking

This container aims to provide Internet access to the virtual machines and the containers.
The container has 4 local Vlans:

- VLAN 10 (192.168.10.0/24) for host machines 
- VLAN 20 (192.168.20.0/24) for DMZ 
- VLAN 30 (192.168.30.0/24) for VMs 
- VLAN 40 (192.168.40.0/24) for LXCs

## Firewall

The firewall is configured to block any incoming connection. But the **openwrt** is fully accessible through the LAN zone.

## TODO

- Check system performances.
