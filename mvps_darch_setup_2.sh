#!/bin/bash

# VARIABLES
LV_DARCH_NAME="darch_images"
LV_SMALLROOT_NAME="small_root"
DARCH_IMAGE="pauldotknopf/darch-arch-base"
VG_NAME=$(vgs --noheadings | awk '{print$1}')  # Assume there is only 1 VG

# Remove old root
lvremove $VG_NAME root -y
lvextend $VG_NAME/$LV_SMALLROOT_NAME -L 8G --resizefs

# Create LV for darch
lvcreate -n $LV_DARCH_NAME -L 5G $VG_NAME --verbose --yes
LV_DARCH_PATH=$(lvs -o lv_path $VG_NAME/$LV_DARCH_NAME --noheadings | tr -d " ")
mkfs.xfs $LV_DARCH_PATH
mkdir -p /var/lib/darch
mount $LV_DARCH_PATH /var/lib/darch
mkdir -p /var/lib/darch/containerd/tmpmounts
# TODO: Mount tmpmounts on root
genfstab -U / -p > /etc/fstab

# Install darch
apt-get update
apt-get install curl gnupg software-properties-common -y
curl -L https://raw.githubusercontent.com/godarch/debian-repo/master/key.pub | apt-key add -
add-apt-repository 'deb https://raw.githubusercontent.com/godarch/debian-repo/master/darch testing main'
apt-get update
apt-get install darch -y
mkdir -p /etc/containerd
echo "root = \"/var/lib/darch/containerd\"" > /etc/containerd/config.toml
systemctl enable containerd
grub-mkconfig -o /boot/grub/grub.cfg

# Setup darch usage
darch images pull $DARCH_IMAGE
darch stage upload $DARCH_IMAGE
