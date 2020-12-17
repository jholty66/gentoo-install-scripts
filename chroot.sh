#!/bin/sh

/usr/sbin/env-update
source /etc/profile
source /root/custom.sh

### Syncronise portage.
echo -e "\nUpdating portage.\n"
time (emerge-webrsync && $EMERGE --update --deep --newuse @world)

### Configuration.
echo -e "\nConfiguraing timezone and locale."
echo "Europe/London" > /etc/timezone
emerge --ask=n --config sys-libs/timezone-data
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
env-update && source /etc/profile; source /root/custom.sh

### fstab
# genfstab, from the arch-install-scripts
# https://github.com/archlinux/arch-install-scripts, is used to create
# the fstab file. This is more reliable and is easier to work with when
# installing gentoo on different hardware.
echo -e "\nCreating fstab\n"
$EMERGE app-portage/layman dev-vcs/git
layman -L
yes | layman -a zscheile
$EMERGE --nodeps arch-install-scripts asciidoc
cp /etc/fstab{,.def}
echo -e "\nGenerating fstab.\n"
genfstab -U -p / >> /etc/fstab
cat /etc/fstab

### Kernel
echo -e "\nEmerging kernel sources.\n"
$EMERGE sys-kernel/gentoo-sources sys-kernel/genkernel linux-firmware
echo -e "\nCompiling kernel.\n"
DIR=$(pwd)
cd /usr/src/linux
make menuconfig
time (echo $GENKERNEL | source /dev/stdin)
cd $DIR

### Tools and services.
echo -e "\nEmerging system tools.\n"
$EMERGE sysklogd cronie mlocate dosfstools dhcpcd gentoolkit $TOOLS
echo -e "\nEnabling services at startup\n"
systemctl enable cronie
systemctl enable dhcpcd
systemctl enable sshd
systemctl enable sysklogd
$SERVICES

### Root password
echo -e "\nCreate root passowrd\n"
passwd

### Bootloader
# TODO: Learn how to install efistub
# $INSTALL_BOOTLOADER

$EMERGE efibootmgr
install_bootloader
