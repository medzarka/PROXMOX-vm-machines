
# ---------------------------------------------------
# Create the new NAS machine
echo "------------------------------------------------------"
echo "Destroy the old VM (with wait of 5 seconds)"
qm stop 100 --timeout 5
qm destroy 100 --destroy-unreferenced-disks 1 --purge 1 --skiplock 1

echo "------------------------------------------------------"
echo "Create the openwrt VM based on the template 7000"
qm clone 7000 100 --name openwrt --full --storage local-lvm
qm set 100 --memory 1024
qm set 100 --tags _wan,openwrt
qm set 100 --onboot 1

echo "------------------------------------------------------"
echo "Start the VM with wait of 25 seconds"
qm start 100 --timeout 10

sleep 25

## TODO in clone vms
# root password hint: qm guest passwd $VMID root
# root ssh key

echo "------------------------------------------------------"
echo "Configure the VM"


if [ -f "/root/.ssh/id_dropbear" ]; then
    echo "dropbear key already created"
else 
    echo "create dropbear public key"
    apt install dropbear -y
    dropbearkey -f ~/.ssh/id_dropbear -t rsa -s 2048
    apt remove dropbear --purge -y
fi

echo "create the setup file"
cat << EOF > setup.sh
ROOT_PASS=\`cat /root/user_pass\`
mount_root
echo -e "\$ROOT_PASS\n\$ROOT_PASS" | (passwd root)
cat /root/id_rsa.pub >> /etc/dropbear/authorized_keys
rm -rf /root/id_rsa.pub
rm -rf /root/user_pass
rm -rf /root/setup.sh
#reboot
EOF

echo "copy files to the VM"
scp -O setup.sh root@192.168.10.1:/root
scp -O /root/.ssh/user_pass root@192.168.10.1:/root
scp -O /root/.ssh/id_rsa.pub root@192.168.10.1:/root

echo "Exceute the setup on the VM"
qm guest exec 100 -- /bin/sh /root/setup.sh

echo "Cleaning"
rm -rf setup.sh

echo "Reboot the VM"
qm reboot 100



