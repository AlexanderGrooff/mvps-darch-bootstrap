#!/bin/bash

# VARIABLES
LV_SMALLROOT_NAME="small_root"

# Disable swap
swapoff -a
grep -v swap /etc/fstab > /tmp/new_fstab
mv /tmp/new_fstab /etc/fstab

# Use swap diskspace to create new small root volume
LV_SWAP_PATH=$(lvscan | grep swap | cut -d\' -f 2)
VG_NAME=$(vgs --noheadings | awk '{print$1}')  # Assume there is only 1 VG
lvremove $LV_SWAP_PATH --verbose --yes
VG_FREESPACE=$(vgs $VG_NAME --options vg_free --no-headings | awk '{print$1}')  # Awk is to remove spaces
lvcreate -n $LV_SMALLROOT_NAME -L $VG_FREESPACE $VG_NAME --verbose --yes
LV_SMALLROOT_PATH=$(lvs -o lv_path $VG_NAME/$LV_SMALLROOT_NAME --noheadings | tr -d " ")

# Remove mentions of swap LV
update-grub
update-initramfs -u
> /etc/initramfs-tools/conf.d/resume

# Setup xfs on new volume
apt-get install xfsprogs arch-install-scripts rsync -y
mkfs.xfs $LV_SMALLROOT_PATH
mount $LV_SMALLROOT_PATH /mnt

# Move old root to new root
rsync -axHAWXS --numeric-ids --info=progress2 / /mnt/
arch-chroot /mnt mount /dev/vda1 /boot
genfstab -U -p /mnt > /mnt/etc/fstab
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Reboot, from this point we're on small_root
echo "Disk setup done. Rebooting.."
reboot
