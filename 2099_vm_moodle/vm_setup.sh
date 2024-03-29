#!/bin/bash

# Specific VM template configurations

# Proxmox
TEMPLATE=5212 # debian 12
VMID=2021
TAGS=_dmz,moodle,education
MACHINE_NAME=moodle
START_ON_PVE_REBOOT=1
STORAGE=local-zfs 

# KVM
RAM=4096
CORES=1
BRIDGE=vmbr1
VLAN=10
EXPAND_DISKIMAGE_SIZE=10G # 0G for no resize

#### CLOUD-INIT
IP=192.168.10.201/24 
GW=192.168.10.1
DNS=192.168.10.1

#### REQUIRED-DATA
VM_DATA=("")
VM_AUTOGENERATED_DATA=("")


# Load common configs from the common scripts
echo "Load common configs from the common scripts"
source ../lib/common_vm_scripts.sh
vm_creation_steps