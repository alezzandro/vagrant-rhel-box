#!/bin/bash
set -x

#tree=../../rhel-server-7.2-x86_64-dvd.iso
tree=http://download.eng.bos.redhat.com/composes/released/RHEL-7/7.2/Server/x86_64/os/

virt-install --connect=qemu:///system \
    --network=bridge:virbr0 \
    --initrd-inject=./rhel-7.2-ci-cloud_edit.ks \
    --extra-args="ks=file:/rhel-7.2-ci-cloud_edit.ks no_timer_check console=tty0 console=ttyS0,115200 net.ifnames=0 biosdevname=0" \
    --name=rhel-vagrant-7.2.x86_64 \
    --disk ./rhel-vagrant-7.2.x86_64.qcow2,size=20,bus=virtio \
    --ram 2048 \
    --vcpus=2 \
    --check-cpu \
    --accelerate \
    --hvm \
    --location=$tree \
    --nographics --noreboot #--debug 

LIBGUESTFS_BACKEND=direct virt-sparsify --compress -o compat=0.10 --tmp ./tmp/ rhel-vagrant-7.2.x86_64.qcow2 box.img

tar cvzf rhel72.box ./metadata.json ./Vagrantfile ./box.img
