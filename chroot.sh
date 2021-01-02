#!/bin/sh
set -e
source custom.sh
# Chroot into install
sh setup-portage.sh locale.sh fstab.sh kernel.sh services.sh bootloader.sh
