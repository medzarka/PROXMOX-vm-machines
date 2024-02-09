# Proxmox
TEMPLATE=5201 # debian 12
VMID=2012
TAGS=_dmz,onlyoffice,groupwork
MACHINE_NAME=ONLYOFFICE
STORAGE=local-lvm

# KVM
RAM=16384
CORES=6
BRIDGE=vmbr1
VLAN=20
DISK_SIZE_EXTEND=+128G

#### Cloud Init
IP=192.168.20.12/24
GW=192.168.20.1
DNS=192.168.20.1
DOMAIN=bluewave.one
USER_NAME=onlyoffice
PASSWORD_LENGTH=100
USER_PASSWORD=$(pass pve01/vms/"$VMID")
if [[ -z "$USER_PASSWORD" ]]; then
    # $USER_PASSWORD is empty, create new one
    pass generate pve01/vms/"$VMID" $PASSWORD_LENGTH -n
    USER_PASSWORD=$(pass pve01/vms/"$VMID")
fi


# ---------------------------------------------------
# Create the new machine
echo "------------------------------------------------------"
echo "Destroy the old VM (with wait of 5 seconds) ..."
qm stop $VMID --timeout 5
qm destroy $VMID --destroy-unreferenced-disks 1 --purge 1 --skiplock 1


# ---------------------------------------------------
# Create the new machine as a clone 
echo "------------------------------------------------------"
echo "Create a new VM machine ..."
qm clone $TEMPLATE $VMID --name $MACHINE_NAME --full --storage $STORAGE
qm set $VMID --memory $RAM
qm set $VMID --cores $CORES
qm set $VMID --tags $TAGS
qm set $VMID --ciuser $USER_NAME
qm set $VMID --cipassword $(openssl passwd -6 $USER_PASSWORD)
qm set $VMID --sshkey /root/.ssh/id_rsa.pub
qm set $VMID --searchdomain $DOMAIN 
#qm set $VMID --ipconfig0 ip=dhcp,ip6=auto
qm set $VMID --ipconfig0 ip=$IP,gw=$GW,ip6=auto
qm set $VMID --nameserver $DNS
qm resize $VMID scsi0 $DISK_SIZE_EXTEND
qm set $VMID --net0 virtio,bridge=$BRIDGE,tag=$VLAN

qm set $VMID --onboot 1 ## this is important for the present VM

qm start $VMID


# ---> in the VM:
sudo apt install parted
sudo parted /dev/sda # print --> resizepart 1 100% --> print --> quit
sudo resize2fs /dev/sda1