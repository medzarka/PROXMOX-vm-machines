#!/bin/bash

#######################################
routeros_version=7.13.5
routeros_img_dir=/root
template_vm_id=10000
#######################################

#### Install script
#https://download.mikrotik.com/routeros/7.13.5/chr-7.13.5.img.zip
routeros_img_name=chr-${routeros_version}.img.zip
routeros_img_url=https://download.mikrotik.com/routeros/${routeros_version}/$routeros_img_name
routeros_img_path=$routeros_img_dir/$routeros_img_name
routeros_unzipped_image_path=/root/chr-${routeros_version}.img
template_name="template-routeros-${routeros_version}"
template_tags="_template,os_routeros,v_${routeros_version}"

echo ''
echo "### Download routeros image (version $routeros_version)..."
echo ''
if [ -e $routeros_unzipped_image_path ]
then
    echo "The routeros image file is already downloaded."
else
    echo "Downloading the routeros image file"
    wget $routeros_img_url -O $routeros_img_path
    unzip $routeros_img_path -d $routeros_img_dir
fi

echo ''
echo "### Create the proxmox virtual machine with ID=$template_vm_id..."
echo ''
qm destroy $template_vm_id
qm create $template_vm_id --name $template_name --ostype l26
qm set $template_vm_id --net0 virtio,bridge=vmbr0
qm set $template_vm_id --net1 virtio,bridge=vmbr1
qm set $template_vm_id --serial0 socket --vga serial0
qm set $template_vm_id --memory 256 --cores 2 --cpu host
qm set $template_vm_id --machine q35 
qm set $template_vm_id --scsi0 local-lvm:0,import-from=$routeros_unzipped_image_path,aio=io_uring,cache=unsafe,discard=on,iothread=1,ssd=1
qm set $template_vm_id --boot order=scsi0 --scsihw virtio-scsi-single
qm set $template_vm_id --tablet 0 
qm set $template_vm_id --tags $template_tags 
qm disk resize $template_vm_id scsi0 512M
qm template $template_vm_id

echo ''
echo '### Cleaning ...'
echo ''
rm -f $routeros_unzipped_image_path
rm -f $routeros_img_path

echo ''
echo '### Done.'
echo ''

