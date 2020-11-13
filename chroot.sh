#!/bin/sh

/usr/sbin/env-update
source /etc/profile
source /root/custom.sh

### Syncronise portage.
echo "
Updating portage.
"
time (emerge-webrsync && $EMERGE --update --deep --newuse @world)

### Configuration.
echo "
Configuraing timezone and locale."
echo "Europe/London" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "en_GB.UTF-8 UTF-8"
locale-gen
env-update && source /etc/profile; source /root/custom.sh

### fstab
# genfstab, from the arch-install-scripts
# https://github.com/archlinux/arch-install-scripts, is used to create
# the fstab file. This is more reliable and is easier to work with when
# installing gentoo on different hardware.
echo "
Creating fstab"
cp /etc/fstab{,.def}
/root/genfstab.sh -U -p / >> /etc/fstab

### Kernel
echo "
Emerging kernel sources.
"
$EMERGE sys-kernel/gentoo-sources sys-kernel/genkernel linux-firmware
echo "
Compiling kernel.
"
DIR=$(pwd)
cd /usr/src/linux
make menuconfig
time $GENKERNEL
cd $DIR

### Tools and services.
echo "
Emerging system tools.
"
$EMERGE sysklogd cronie mlocate dosfstools dhcpcd gentoolkit $TOOLS
echo "
Enabling services at startup
"
systemctl enable cronie
systemctl enable dhcpcd
systemctl enable sshd
systemctl enable sysklogd
$SERVICES

### Root password
echo "
Create root passowrd
"
passwd

### Bootloader
# TODO: Learn how to install efistub
# $INSTALL_BOOTLOADER

$EMERGE efibootmgr
install_bootloader
