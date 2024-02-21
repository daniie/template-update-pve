#!/bin/bash

MNTDEBIAN=/mnt/debianconf
IMAGEDISK=/dev/nbd0
IMAGEPART=/dev/nbd0p1 
DLIMAGE=https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
VMID=8010
DISKIMAGE=/root/script/debian12.qcow2
DISK=scsi0
DEBIANCLOUDCFG=/mnt/debianconf/etc/cloud/cloud.cfg.d/01_debian_cloud.cfg
CLOUDCFG=/mnt/debianconf/etc/cloud/cloud.cfg


wget $DLIMAGE -O $DISKIMAGE


modprobe nbd max_part=8
qemu-nbd --connect=$IMAGEDISK $DISKIMAGE
sleep 1;

mkdir $MNTDEBIAN
sleep 1;

mount $IMAGEPART $MNTDEBIAN

sleep 3;

sed -i -e 's/debian/ansible/g' $DEBIANCLOUDCFG
printf "package_update: true\n" >> $CLOUDCFG
printf "package_upgrade: true\n" >> $CLOUDCFG
printf "package_reboot_if_required: true\n" >> $CLOUDCFG
printf "timezone: Europe/Stockholm\n" >> $CLOUDCFG
printf "packages:\n  - git\n  - qemu-guest-agent\n" >> $CLOUDCFG
printf "runcmd:\n  - [ systemctl, start, qemu-guest-agent.service ]\n  - [ reboot, -h, now ]\n" >> $CLOUDCFG



sleep 3;

umount $MNTDEBIAN

qemu-nbd --disconnect $IMAGEDISK

rm -rf $MNTDEBIAN

sleep 5;
rmmod nbd


qm set $VMID --delete $DISK
qm set $VMID --delete unused0

qm importdisk $VMID $DISKIMAGE local-lvm

qm set $VMID --scsihw virtio-scsi-pci --$DISK local-lvm:vm-$VMID-disk-0

qm resize $VMID $DISK +8G

rm $DISKIMAGE
