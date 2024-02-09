#!/bin/sh
USER_PASSWORD=`cat /root/.ssh/user_pass`
SSH_KEY=`cat /root/.ssh/id_rsa.pub`


ROOT_PASS=`cat /root/secret`
rm -f /root/secret

qm guest exec 100 -- echo "$USER_PASSWORD" >  /root/secret
qm guest exec 100 -- mount_root && ROOT_PASS=`cat /root/secret` && echo "root:$USER_PASSWORD" | chpasswd

