#### install python virtualenv
apt install python3.11-venv
python3 -m venv /root/.pyenv
python_bin=/root/.pyenv/bin/python
pip_bin=/root/.pyenv/bin/pip

#######################################
routeros_version=7.13.5
routeros_img_dir=/root
VMID=
#######################################

#### Install script
#https://download.mikrotik.com/routeros/7.13.5/chr-7.13.5.img.zip
routeros_img_name=chr-${routeros_version}.img.zip
routeros_img_url=https://download.mikrotik.com/routeros/${routeros_version}/$routeros_img_name
routeros_img_path=$routeros_img_dir/$routeros_img_name
routeros_unzipped_image_path=/root/chr-${routeros_version}.img

echo '### Download routeros image ...'
if [ -e $routeros_unzipped_image_path ]
then
    echo "The routeros image file is already downloaded."
else
    echo "Downloading the routeros image file"
    wget $routeros_img_url -O $routeros_img_path
    unzip $routeros_img_path -d $routeros_img_dir
fi

echo '### Create the proxmox virtual machine ...'
qm destroy 101
qm create 101 --name "temp-mikrotik-ros-7.11.2" --ostype l26
qm set 101 --net0 virtio,bridge=vmbr0
qm set 101 --net1 virtio,bridge=vmbr1
qm set 101 --serial0 socket --vga serial0
qm set 101 --memory 256 --cores 2 --cpu host
qm set 101 --scsi0 local-lvm:0,import-from="/root/chr-7.11.2.img",discard=on
qm set 101 --boot order=scsi0 --scsihw virtio-scsi-single
qm disk resize 101 scsi0 1G
#qm template 101

#### Config script
$pip_bin install routeros_api
$python_bin os_setup.sh




