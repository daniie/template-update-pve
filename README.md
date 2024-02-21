# template-update-pve

This bash script automates the process of downloading, modifying, and deploying a Debian 12 (Bookworm) QCOW2 image for use with a virtual machine (VM), specifically targeting an environment managed by Proxmox VE (Virtual Environment). Here's a step-by-step summary of what it does:

1. **Download Debian Image**: It downloads the latest Debian 12 (Bookworm) QCOW2 image from the Debian Cloud images repository and saves it as `/root/script/debian12.qcow2`.

2. **Prepare NBD (Network Block Device)**: Loads the `nbd` kernel module with support for up to 8 partitions, and connects the downloaded disk image to `/dev/nbd0` using `qemu-nbd`, making it accessible as a block device.

3. **Mount Image Partition**: Creates a mount point at `/mnt/debianconf`, waits for the device to be ready, and then mounts the first partition of the disk image (`/dev/nbd0p1`) to this mount point.

4. **Modify Cloud-Init Configuration**: Edits the cloud-init configuration to:
   - Change the default user from `debian` to `ansible` in the Debian cloud configuration file.
   - Enable automatic package updates, upgrades, and reboot if required in the main cloud configuration file.
   - Set the timezone to Europe/Stockholm.
   - Install additional packages (`git` and `qemu-guest-agent`).
   - Run commands to start the `qemu-guest-agent` service and reboot the machine as part of the VM's first boot sequence.

5. **Unmount and Clean Up**: Unmounts the partition, disconnects the NBD device, and removes the NBD kernel module. It also cleans up by deleting the mount point directory.

6. **Proxmox VM Configuration**:
   - Deletes any existing disk configuration associated with the VM specified by `VMID`.
   - Imports the modified disk image into Proxmox's local-lvm storage, assigning it to the VM.
   - Sets the SCSI hardware type to `virtio-scsi-pci` and associates the imported disk with the VM as a SCSI device.
   - Resizes the VM's disk size by adding an additional 8GB.

7. **Final Cleanup**: Deletes the downloaded and modified QCOW2 disk image to free up space.

In essence, this script streamlines the process of setting up a Debian 12 VM with custom cloud-init configurations for use in a Proxmox VE environment, including downloading the image, making required modifications, and configuring the VM within Proxmox.
