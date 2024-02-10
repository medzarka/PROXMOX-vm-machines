
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

    echo "   execute the script on the VM"
    ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $DEFAULT_USER@$IPP 'sh -s' < os_system_setup.sh
    echo "   the execution of the script on the template is done."
    
    
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

}

destroy_old_vm(){

    VM_ID=$1
    echo ""
    echo "-----------------------------------------------------------------"
    if [ -n "$VM_ID" ] ; then
        echo "Destroying the old VM wit ID $VM_ID ..."
        sudo qm shutdown $VM_ID --timeout 30
        sudo qm destroy $VM_ID --destroy-unreferenced-disks 1 --purge 1 
    else
        echo "ERROR: VM_ID is not well provided for the destroy_old_vm function."
        echo "Exiting."
        exit -1
    fi
}

create_retrive_common_variable_from_pass()
{
    RETURN_VALUE=""
    DATA_NAME=$1

    if [ -n "$DATA_NAME" ]; then 

        DATA_PATH="pve01/templates/common/$DATA_NAME"
        DATA_VALUE=$(pass $DATA_PATH)  
        if [[ -z "$DATA_VALUE" ]]; then 
            echo "The $DATA_NAME variable is not defined, please type it twice (like a password):"
            pass insert $DATA_PATH
            DATA_VALUE=$(pass $DATA_PATH)  
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

create_retrive_specific_vm_variable_from_pass()
{
    RETURN_VALUE=""
    VM_ID=$1
    DATA_NAME=$2

    if [ -n "$VM_ID" ] && [ -n "$DATA_NAME" ]; then

        DATA_PATH="pve01/templates/$VM_ID/$DATA_NAME"
        DATA_VALUE=$(pass $DATA_PATH)  
        if [[ -z "$DATA_VALUE" ]]; then 
            echo "The $DATA_NAME variable for the VM $VM_ID is not defined, please type it twice (like a password):"
            pass insert $DATA_PATH
            DATA_VALUE=$(pass $DATA_PATH)  
            echo "The $DATA_NAME for the VM $VM_ID is defined to $DATA_VALUE"
        else
            echo "The $DATA_NAME for the VM $VM_ID is already defined to $DATA_VALUE"
        fi

        RETURN_VALUE=$DATA_VALUE
        
    else
        echo "ERROR: The DATA_NAME/VM_ID are not well defined for the create_retrive_specific_vm_variable_from_pass function. Exiting" 
        exit -1
    fi
}

create_retrive_specific_vm_user_password_from_pass()
{
    RETURN_VALUE=""
    VM_ID=$1
    DEFAULT_PASSWORD_LENGTH=$2
    DATA_NAME="default_user_password"

    if [ -n "$VM_ID" ] && [ -n "$DEFAULT_PASSWORD_LENGTH" ]; then

        DATA_PATH="pve01/vms/$VM_ID/$DATA_NAME"
        DATA_VALUE=$(pass $DATA_PATH)  
        if [[ -z "$DATA_VALUE" ]]; then 
            echo "The $DATA_NAME variable for the VM $VM_ID is not defined, we will generate a new one."
            pass generate $DATA_PATH $DEFAULT_PASSWORD_LENGTH -n 
            DATA_VALUE=$(pass $DATA_PATH)  
            echo "The $DATA_NAME for the VM $VM_ID is defined to $DATA_VALUE"
        else
            echo "The $DATA_NAME for the VM $VM_ID is already defined to $DATA_VALUE"
        fi

        RETURN_VALUE=$DATA_VALUE
        
    else
        echo "ERROR: The DEFAULT_PASSWORD_LENGTH/VM_ID are not well defined for the create_retrive_specific_vm_user_password_from_pass function. Exiting" 
        exit -1
    fi
}
