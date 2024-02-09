#!/bin/sh

## ------------------------------------------------------------------------
# Step 1 - configure the storage disk

# add the disk 1 (scsi1 --> /dev/sdb)
doas pvcreate /dev/sdb
doas vgcreate nas0 /dev/sdb
doas lvcreate -n storage -l 100%FREE nas0
doas mkfs.ext4 /dev/nas0/storage
doas mkdir -p /nfs/storage
cat <<EOF >> /etc/fstab
# NFS starage 
/dev/nas0/storage   /nfs/storage    ext4    rw,relatime 0 3
EOF
doas mount -a


# extend the volume with new disk (scsi2 --> /dev/sdc)
#parted /dev/sdc # print --> mklabel gpt --> mkpart --> start 0 --> end 1000 --> resizepart 1 100% --> print --> quit
doas pvcreate /dev/sdc
doas vgextend nas0 /dev/sdc
doas umount /nfs/storage/
doas lvextend -r -l +100%FREE /dev/nas0/storage
doas mount /nfs/storage/

# extend the volume with new disk (scsi3 --> /dev/sdd)
#parted /dev/sdc # print --> mklabel gpt --> mkpart --> start 0 --> end 1000 --> resizepart 1 100% --> print --> quit
doas pvcreate /dev/sdd
doas vgextend nas0 /dev/sdd
doas umount /nfs/storage/
doas lvextend -r -l +100%FREE /dev/nas0/storage
doas mount /nfs/storage/

## ------------------------------------------------------------------------
# Step 2 - configure the backup with rclone
# TODO


## ------------------------------------------------------------------------
# Step 3 - install and configure the NFS server
doas apk add --no-cache nfs-utils 
doas mkdir -p /nfs/storage
#nano /etc/exports
cat <<EOF > /etc/exports
# extremely insecure
/nfs/storage    *(rw,async,no_subtree_check,no_wdelay,crossmnt,no_root_squash,insecure_locks,sec=sys,anonuid=0,anongid=0)
EOF
doas rc-service nfs start
doas rc-update add nfs
doas rc-status # to check
doas exportfs -afv
reboot


## ------------------------------------------------------------------------
# Step 4 - Give access to NFS from the local network only
ufw default allow outgoing
doas ufw allow from 192.168.0.0/16 to any port nfs
