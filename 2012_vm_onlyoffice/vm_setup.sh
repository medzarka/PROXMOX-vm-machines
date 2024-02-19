#!/bin/bash

# [x] Load common configs from the common scripts
echo "Load common configs from the common scripts"
source ../lib/common_vm_scripts.sh

# [x] Specific VM template configurations

# Proxmox
TEMPLATE=5212 # debian 12
VMID=2012
TAGS=_dmz,onlyoffice,groupwork
MACHINE_NAME=ONLYOFFICE
START_ON_PVE_REBOOT=1
STORAGE=local-lvm 

# KVM
RAM=12288
CORES=4
BRIDGE=vmbr1
VLAN=20
EXPAND_DISKIMAGE_SIZE=80G # 0G for no resize

#### Cloud Init
IP=192.168.20.12/24
GW=192.168.20.1
DNS=192.168.20.1

#### required data
DATA=()
AUTOGENERATED_DATA=(VSCODE_PASSKEY)


echo "-----------------------------------------------------------------"
echo "Create the $MACHINE_NAME machine"
echo "-----------------------------------------------------------------"

# [x] Load common VM template configurations

create_retrive_common_variable_from_pass "default_domain"
MAIN_DOMAIN=$RETURN_VALUE
create_retrive_common_variable_from_pass "default_user"
DEFAULT_USER=$RETURN_VALUE
create_retrive_common_variable_from_pass "default_password_length"
DEFAULT_PASSWORD_LENGTH=$RETURN_VALUE
create_retrive_specific_vm_user_password_from_pass $VMID $DEFAULT_PASSWORD_LENGTH
USER_PASSWORD=$RETURN_VALUE


STORAGE=local-lvm   


#############################################################
### Destroy the old VM if it exists
destroy_old_vm $VMID

#############################################################
### Create new VM
create_new_vm

#############################################################
### Start the VM template, wait it to start, and then execute the setup script 
template_os_setup


#############################################################
echo "-----------------------------------------------------------------"
echo "Done for the $MACHINE_NAME machine"
echo "-----------------------------------------------------------------"