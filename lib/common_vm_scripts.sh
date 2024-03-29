
vm_creation_steps(){
    echo "-----------------------------------------------------------------"
    echo "Create the $MACHINE_NAME machine"
    echo "-----------------------------------------------------------------"

    # Load common VM template configurations
    create_retrive_common_variable_from_pass "default_domain"
    MAIN_DOMAIN=$RETURN_VALUE
    create_retrive_common_variable_from_pass "default_user"
    DEFAULT_USER=$RETURN_VALUE
    create_retrive_common_variable_from_pass "default_password_length"
    DEFAULT_PASSWORD_LENGTH=$RETURN_VALUE
    create_retrive_vm_autogenerated_variable_from_pass $VMID "user_password" $DEFAULT_PASSWORD_LENGTH
    USER_PASSWORD=$RETURN_VALUE

    # Load VM template configurations
    load_vm_data

    # Destroy the old VM if it exists
    destroy_old_vm $VMID

    # Create new VM
    create_new_vm

    # Start the VM template, wait it to start, and then execute the setup script
    template_os_setup
     
    echo "-----------------------------------------------------------------"
    echo "Done for the $MACHINE_NAME machine (ID=$VMID) (IP=$IP)"
    echo "-----------------------------------------------------------------"
}

# the follwoing function will try to load data (DATA and AUTOGENERATED_DATA) from pass.
# If the data does not exist, then it will be generated (for AUTOGENERATED).
# The data generated are stored in the .env foler: each data is stored in a separated file having the same name as the data name.
load_vm_data(){

    sudo rm -rf .env
    sudo mkdir -p .env

    for A_DATA in "${VM_DATA[@]}"
    do
        if [ "$A_DATA" != "" ]
        then
            RETURN_VALUE=""
            create_retrive_vm_variable_from_pass $VMID $A_DATA
            DATA_VALUE=$RETURN_VALUE
            echo "$DATA_VALUE" | sudo tee -a ".env/secret_$A_DATA" > /dev/null
        fi
    done
 
    for AA_DATA in "${VM_AUTOGENERATED_DATA[@]}"
    do
        if [ "$AA_DATA" != "" ]
        then
            RETURN_VALUE=""
            create_retrive_vm_autogenerated_variable_from_pass $VMID $AA_DATA $DEFAULT_PASSWORD_LENGTH
            DATA_VALUE=$RETURN_VALUE
            echo "$DATA_VALUE" | sudo tee -a ".env/secret_$AA_DATA" > /dev/null
        fi
    done

    sudo sync
}

template_os_setup(){
    echo "-----------------------------------------------------------------"
    echo "Configuring the VM OS system ..."

    echo "   start the VM"
    sudo qm start $VMID

    echo "  waiting the system to be fully loaded and the port 22 is open."
    IPP=$(echo $IP | cut -d '/' -f1)
    while true; do
        nc -z -v -w60 $IPP 22 >> /dev/null 2>&1
        result=$?
        if [  "$result" != 0 ]; then
            echo "     still waiting"
            sleep 3
        else
            break
        fi
    done

    echo "   copy the .env to the VM (under root/ folder)"    
    if [ ! -d ".env" ]; then
        echo ".env does not exist. We create it."
        sudo mkdir -p .env
    fi
    scp -q -v -r -o "BatchMode=yes" -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" .env/ $DEFAULT_USER@$IPP:/home/$DEFAULT_USER

    echo "   execute the script on the VM"
    ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $DEFAULT_USER@$IPP 'bash -s' < os_system_setup.sh
    echo "   the execution of the script on the template is done."

    sudo sync
    
}

create_new_vm(){
    echo "-----------------------------------------------------------------"
    echo "Clone the new VM ..."
    sudo qm clone $TEMPLATE $VMID --name $MACHINE_NAME --full --storage $STORAGE
    sudo qm set $VMID --net0 virtio,bridge=$BRIDGE,tag=$VLAN  
    sudo qm set $VMID --memory $RAM 
    sudo qm set $VMID --cores $CORES --cpu cputype=host 
    sudo qm set $VMID --tags $TAGS 
    sudo qm set $VMID --ciuser $DEFAULT_USER 
    sudo qm set $VMID --cipassword $(openssl passwd -6 $USER_PASSWORD) 
    sudo qm set $VMID --sshkeys /root/.ssh/authorized_keys 
    sudo qm set $VMID --ipconfig0 ip=$IP,gw=$GW,ip6=auto
    sudo qm set $VMID --nameserver $DNS 
    sudo qm set $VMID --searchdomain $MAIN_DOMAIN 
    sudo qm set $VMID --ciupgrade 0

    if [ $EXPAND_DISKIMAGE_SIZE != "0G" ]
    then
        echo "Update the disk image size to $EXPAND_DISKIMAGE_SIZE ..."
        sudo qm disk resize $VMID scsi0 $EXPAND_DISKIMAGE_SIZE
    else
        echo "Disk image resize ignored"
    fi

    if [ $START_ON_PVE_REBOOT == "1" ]
    then
        sudo qm set $VMID --onboot 1
    fi

    echo "flash the disk cache"
    sudo sync
}

destroy_old_vm(){

    VM_ID=$1
    echo ""
    echo "-----------------------------------------------------------------"
    if [ -n "$VM_ID" ] ; then
        echo "Destroying the old VM wit ID $VM_ID ..."
        sudo qm shutdown $VM_ID --timeout 30
        sudo qm stop $VM_ID --timeout 30
        sudo qm destroy $VM_ID --destroy-unreferenced-disks 1 --purge 1 
    else
        echo "ERROR: VM_ID is not well provided for the destroy_old_vm function."
        echo "Exiting."
        exit -1
    fi
    sudo sync
}
#### Retrieve common data
create_retrive_common_variable_from_pass()
{
    RETURN_VALUE=""
    DATA_NAME=$1

    if [ -n "$DATA_NAME" ]; then 
        echo "####### Load the COMMON DATA: $DATA_NAME"
        DATA_PATH="pve01/vms/common/$DATA_NAME"
        DATA_VALUE=$(sudo pass $DATA_PATH)  
        if [[ -z "$DATA_VALUE" ]]; then 
            echo "The $DATA_NAME variable is not defined, please type it twice (like a password):"
            sudo pass insert $DATA_PATH
            DATA_VALUE=$(sudo pass $DATA_PATH)  
            echo "The $DATA_NAME is defined to $DATA_VALUE"
        else
            echo "The $DATA_NAME is already defined to $DATA_VALUE"
        fi

        RETURN_VALUE=$DATA_VALUE

    else
        echo "ERROR: The DATA_NAME is not defined for the create_retrive_common_variable_from_pass function. Exiting" 
        exit -1
    fi
}

create_retrive_common_autogenerated_variable_from_pass()
{
    RETURN_VALUE=""
    DATA_NAME=$1
    DEFAULT_PASSWORD_LENGTH=$2

    if [ -n "$DATA_NAME" ] && [ -n "$DEFAULT_PASSWORD_LENGTH" ]; then 
        echo "####### Load the COMMON AUTOGENERATED DATA: $DATA_NAME"
        DATA_PATH="pve01/vms/common/$DATA_NAME"
        DATA_VALUE=$(sudo pass $DATA_PATH)  
        if [[ -z "$DATA_VALUE" ]]; then 
            sudo pass generate $DATA_PATH $DEFAULT_PASSWORD_LENGTH -n 
            DATA_VALUE=$(sudo pass $DATA_PATH)  
            echo "The $DATA_NAME is defined to $DATA_VALUE"
        else
            echo "The $DATA_NAME is already defined to $DATA_VALUE"
        fi

        RETURN_VALUE=$DATA_VALUE

    else
        echo "ERROR: The DATA_NAME is not defined for the create_retrive_common_autogenerated_variable_from_pass function. Exiting" 
        exit -1
    fi
}


#### Retrieve vm data

create_retrive_vm_variable_from_pass()
{
    RETURN_VALUE=""
    VMID=$1
    DATA_NAME=$2

    if [ -n "$VMID" ] && [ -n "$DATA_NAME" ]; then 
        echo "####### Load the DATA: $DATA_NAME for the VM: $VMID"
        DATA_PATH="pve01/vms/$VMID/$DATA_NAME"
        DATA_VALUE=$(sudo pass $DATA_PATH)  
        if [[ -z "$DATA_VALUE" ]]; then 
            echo "The $DATA_NAME variable is not defined, please type it twice (like a password):"
            sudo pass insert $DATA_PATH
            DATA_VALUE=$(sudo pass $DATA_PATH)  
            echo "The $DATA_NAME is defined to $DATA_VALUE"
        else
            echo "The $DATA_NAME is already defined to $DATA_VALUE"
        fi

        RETURN_VALUE=$DATA_VALUE

    else
        echo "ERROR: The DATA_NAME is not defined for the create_retrive_vm_variable_from_pass function. Exiting" 
        exit -1
    fi
}

create_retrive_vm_autogenerated_variable_from_pass()
{
    RETURN_VALUE=""
    VMID=$1
    DATA_NAME=$2
    DEFAULT_PASSWORD_LENGTH=$3

    if [ -n "$VMID" ] && [ -n "$DATA_NAME" ] && [ -n "$DEFAULT_PASSWORD_LENGTH" ]; then 
        echo "####### Load the AUTOGENERATED DATA: $DATA_NAME for the VM: $VMID"
        DATA_PATH="pve01/vms/$VMID/$DATA_NAME"
        DATA_VALUE=$(sudo pass $DATA_PATH)  
        if [[ -z "$DATA_VALUE" ]]; then 
            sudo pass generate $DATA_PATH $DEFAULT_PASSWORD_LENGTH -n  
            DATA_VALUE=$(sudo pass $DATA_PATH)  
            echo "The $DATA_NAME is defined to $DATA_VALUE"
        else
            echo "The $DATA_NAME is already defined to $DATA_VALUE"
        fi

        RETURN_VALUE=$DATA_VALUE

    else
        echo "ERROR: The DATA_NAME is not defined for the create_retrive_vm_autogenerated_variable_from_pass function. Exiting" 
        exit -1
    fi
}