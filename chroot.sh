#!/bin/sh
# Chroot into install
set -e
cd /root/gentoo-installer/
source /etc/profile
/usr/sbin/env-update
source ./custom.sh
sh setup-portage.sh
sh locale.sh
sh fstab.sh
sh kernel.sh
sh services.sh
sh bootloader.sh
