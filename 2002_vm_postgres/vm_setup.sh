
# Proxmox
TEMPLATE=5001 # alpine
VMID=3002
TAGS=_vms,tunnels
MACHINE_NAME=TUNNELS
STORAGE=local-lvm

# KVM
RAM=512
CORES=1
BRIDGE=vmbr1
VLAN=30
DISK_SIZE_EXTEND=+64G

#### Cloud Init
IP=192.168.30.2/24
GW=192.168.30.1
DNS=192.168.30.1
DOMAIN=bluewave.one
USER_NAME=tunnels
PASSWORD_LENGTH=50
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

echo "------------------------------------------------------"
echo "Start the VM with wait of 25 seconds"
qm start $VMID --timeout 10
sleep 25

echo "------------------------------------------------------"
echo "NOTICE ..."
echo "------------------------------------------------------"
echo "After creating the VM, execute the following commands in its shell:"
echo "   - doas apk update"
echo "   - doas apk add parted"
echo "   - doas parted /dev/sda (print --> resizepart 2 100% --> print --> quit)"
echo "   - doas pvresize /dev/sda2 (extend the physical volume /dev/sda2)"
echo "   - doas pvdisplay (to check)"
echo "   - doas lvextend -l +100%FREE  /dev/vg0/lv_root"
echo "   - doas resize2fs /dev/vg0/lv_root"
echo "   - doas reboot"
echo "------------------------------------------------------"

