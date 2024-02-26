#!/bin/bash

##############################
python_venv_name=.pyenv
python_venv_path=/root

template_id=10000
vm_id=101
vm_name='routeros'


##############################

#### install python virtualenv
echo ''
echo "### Install python virtualenv"
echo ''
sudo apt-get install python3.11-venv
python3 -m venv $python_venv_path/$python_venv_name
python_bin=$python_venv_path/$python_venv_name/bin/python
pip_bin=$python_venv_path/$python_venv_name/bin/pip
$pip_bin install routeros_api

echo ''
echo "### Clone the vm $vm_id from the template $template_id ..."
echo ''

qm shutdown $vm_id
qm destroy $vm_id
qm clone $template_id $vm_id --full --name $vm_name
qm set $vm_id --onboot 1
qm start $vm_id

echo ''
echo "### Configure the routeros through API ..."
echo ''
sleep 10
$python_bin os_setup.py

echo ''
echo "### Done."
echo ''




