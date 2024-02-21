sudo apt install python3-pip
sudo pip3 install routeros_api

#### install python virtualenv
apt install python3.11-venv
python3 -m venv .pyenv
python_bin=.pyenv/bin/python
pip_bin=.pyenv/bin/pip

#### Install script
wget "https://download.mikrotik.com/routeros/7.11.2/chr-7.11.2.img.zip"
unzip chr-7.11.2.img.zip
qm create 101 --name "temp-mikrotik-ros-7.11.2" --ostype l26
qm set 101 --net0 virtio,bridge=vmbr0
qm set 101 --net1 virtio,bridge=vmbr1
qm set 101 --serial0 socket --vga serial0
qm set 101 --memory 256 --cores 2 --cpu host
qm set 101 --scsi0 local-lvm:0,import-from="$(pwd)/chr-7.11.2.img",discard=on
qm set 101 --boot order=scsi0 --scsihw virtio-scsi-single
qm disk resize 101 scsi0 2G
qm template 101

#### Config script
pip_bin=.pyenv/bin/pip
$pip_bin install routeros_api
$python_bin os_setup.sh




