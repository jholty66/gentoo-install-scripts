#!/bin/bash
. /etc/profile

### Update portage
echo -e "\nUpdating portage.\n"
time emerge-webrsync
time emerge --ask=n --update --deep --newuse @world

### Config
echo -e "\nConfiguring timezones and locales.\n"
echo "Europe/London" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "en_GB.UTF-8 UTF-8" >  /etc/locale.gen
locale-gen
env-update && source /etc/profile

### Fstab
echo "Installing genfstab ..."
time emerge app-portage/layman dev-vcs/git
layman -L
yes | layman -a zscheile
emerge --ask=n --nodeps arch-install-scripts asciidoc
mv /etc/fstab /etc/fstab.def
echo -e "\Generating fstab.\n"
genfstab -U -p / >> /etc/fstab

### Kernel
echo -e "\nEmerging kernel sources.\n"
time emerge --ask=n sys-kernel/gentoo-sources genkernel linux-firmware systemd
echo -e "\nCompiling kernel.\n"
time genkernel --makeopts=-j4 --zfs all
time sh /root/zfs-genkernel.sh
echo -e "\nGenerating inital ramdisk.\n"


### System tools
echo -e "\nEmerging system tools.\n"
time emerge --ask=n sysklogd cronie mlocate btrfs-progs dosfstools dhcpcd gentoolkit sys-fs/zfs sys-fs/zfs-kmod sys-kernel/spl
echo -e "\nEnabling system services.\n"
systemctl enable cronie
systemctl enable dhcpcd
systemctl enable sshd
systemctl enable sysklogd
systemctl enable zfs-import boot
systemctl enable zfs-mount boot
systemctl enable zfs-share default
systemctl enable zfs-zed default
echo -e "\nSet root user password.\n"
passwd

### Bootloader
echo -e "\nInstalling bootloader.\n"
bootctl --path /boot/efi install
touch /boot/efi/loader/entries/gentoo.conf
echo "title Gentoo Host" > /boot/efi/loader/entries/gentoo.conf
echo "linux $(ls vmlinuz*)" > /boot/efi/loader/entries/gentoo.conf
echo "initrd $(ls initramfs*)" > /boot/efi/loader/entries/gentoo.conf
echo "options dobtrfs root=/dev/nvme0n1p2 rootflags=subvol=gentoo" > /boot/efi/loader/entries/gentoo.conf

### Exit
echo -e "\nExiting chroot environment.\n"
