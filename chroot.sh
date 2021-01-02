#!/bin/sh
set -e
/usr/sbin/env-update
source /etc/profile
source /root/custom.sh
time (emerge-webrsync && $EMERGE --update --deep --newuse @world)
echo "Europe/London" > /etc/timezone
emerge --ask=n --config sys-libs/timezone-data
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
env-update && source /etc/profile; source /root/custom.sh
$EMERGE app-portage/layman dev-vcs/git
layman -L
yes | layman -a zscheile
$EMERGE --nodeps arch-install-scripts asciidoc
cp /etc/fstab /etc/fstab.def /etc/fstab.bak
genfstab -U -p / > /etc/fstab
cat /etc/fstab
$EMERGE sys-kernel/gentoo-sources sys-kernel/genkernel linux-firmware
echo -e "\nCompiling kernel.\n"
DIR=$(pwd)
cd /usr/src/linux
make menuconfig
time (echo $GENKERNEL | source /dev/stdin)
cd $DIR
$EMERGE sysklogd cronie mlocate dosfstools dhcpcd gentoolkit $TOOLS
systemctl enable cronie
systemctl enable dhcpcd
systemctl enable sshd
systemctl enable sysklogd
$SERVICES
passwd
$EMERGE efibootmgr
install_bootloader
