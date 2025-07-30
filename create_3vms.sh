#!/bin/bash

VM_LIST=(
	"alma-vm1 192.168.122.60"
	"alma-vm2 192.168.122.65"
	"alma-vm3 192.168.122.70"
)

for entry in "${VM_LIST[@]}"
do
	VM=$(echo $entry | awk '{print $1}')
	IP=$(echo $entry | awk '{print $2}')
	VAR=/var/lib/libvirt/images/alma/
	cp  ${VAR}/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2 ${VAR}/${VM}.qcow2
	qemu-img resize ${VAR}/${VM}.qcow2 +10G

       ./create-cloud-init.sh $VM $IP

	virt-install \
		--name $VM \
		--memory 2048 \
		--vcpus 2 \
		--cpu host-passthrough \
		--os-variant almalinux9 \
		--disk path=${VAR}/${VM}.qcow2,format=qcow2,size=20 \
		--disk path=${VAR}/${VM}-seed.iso,device=cdrom \
	        --graphics none \
		--noautoconsole \
		--virt-type kvm \
		--import \
		--network network=default

done
