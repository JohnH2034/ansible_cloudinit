#!/bin/bash

VM_NAME=$1
IP_ADDR=$2

#PUB_KEY=$(cat /home/ansible/.ssh/id_rsa.pub)

VM_DIR="/tmp/cloud-init/${VM_NAME}"

mkdir -p $VM_DIR
rm -f ${VM_DIR}/{user-data,meta-data,network-config}
cat > user-data <<EOF
#cloud-config

debug: false


users:
  - name: ansible
    shell: /bin/bash
    lock_passwd: false
    plain_text_passwd: ansible
    gecos: Ansible User
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAGaQ8oNCWHqLwAdwYkxF1aJxvZO0HMV+4nXFtCkPKGUDXS3YPwz5J4vZSYKWtTZ/6jcKiyIQ9VQUZbP/WeetD+5hNVy6riwZPPyBrZUZvXJzZJJqA5FgT0H99373gOIPd7isi4gjJOXr67OzzeaTAPushbjJC/F9jaknwaf2fbvhyExD86fiTSB70Jtp4DTD0CNtHK+ja41HJubH5QBIWw9mF7xOokh8I+IDrHDZKJ6hftt3ZrHvylHElc+HVUf41c1CR1HN30xwfh8HkP4xpF4CoMc6VbfZL6fef/jgKTpf0gVomdSJchigIxJ7DbJ5YVXwqaPIuOPicVXh2i+KPq1YDMQh2h1ZnJjM57pzNmfShpRuRZnA7BXTQMOolsGCylTV1eHI10OYg+xWSbtUBzLzqA3q2V7KnWNOMkM6UuD2fsSEwug7NA8vZAGa2shZKBMv4WwKeqxw1NadzMgW3AZeWPWtdtEHjE3DCodpbzwFtmzwfwBHVfClcm1S7wYQxNAzIWGwsINdrNBjS4YbZdqJLs9AaAZ6yrE9sgUPlgZ220zrEkvhvooEbkqXfZ5/78l8gOM5CmsRsJuhusoz2mc2LhdKHSS81yqXp+g3QY/u7+WSVgvdJXFGXb8A6KybzGjtU6agETbf669f9zW8E2u8dqZ1ztPoXPG4Rrnsmtw== ansible@jhtest

disable_root: false
ssh_pwath:  true

hostname: ${VM_NAME}

write_files:
  - path: /etc/motd
    permissions: '0644'
    content: |
      Welcome to cloud-init provisioned ${VM_NAME}

EOF


cat > meta-data <<EOF
instance-id: ${VM_NAME}
local-hostname: ${VM_NAME}
EOF

cat > network-config <<EOF

version: 2
ethernets:
  eth0:
    dhcp4: false
    addresses: [${IP_ADDR}/24]
    gateway4: 192.168.122.1
    nameservers:
      addresses: [192.168.122.1]

EOF

cp -p user-data ${VM_DIR}/user-data
cp -p meta-data  ${VM_DIR}/meta-data
cp -p network-config ${VM_DIR}/network-config

rm -f /var/lib/libvirt/images/alma/${VM_NAME}-seed.iso 

IMAGE_DIR=/var/lib/libvirt/images/alma

genisoimage -output ${IMAGE_DIR}/${VM_NAME}-seed.iso \
   -volid cidata -joliet -rock ${VM_DIR}/user-data ${VM_DIR}/meta-data ${VM_DIR}/network-config

#cloud-init devel schema --config-file ${VM_DIR}/user-data
