#!/bin/sh

# Variables defined further down the file are likely to depend on
# variables defined further up the file.

### Core settings.
# Hardware
BOOTLOADER="efistub" # "efistub", "systemd-boot", "grub2"
CORES=4
# The combination of these is the full path of the ESP, "/dev/nvme0np1".
EFI_DISK="/dev/nvme0n1"
EFI_PARTITION="p1"

# Editor
EDITOR="emacs"

### /etc/porage/ files
# The following is appended to "/etc/portage/make.conf".
MAKE_CONF="EMERGE_DEFAULT_OPTS=\"--ask --keep-going --jobs ${CORES} --load-average ${CORES}.0\"
FEATURES=\"parallel-fetch parallel-install\"
MAKEOPTS=\"-j4 -l4\"
USE=\"systemd threads -gui -sound\" # savedconfig does not currently work for sys-kernel/linux-firmware"

### Shell commands
# Emerge command.
EMERGE="emerge --ask=n"

# Genkernel command.
GENKERNEL="genkernel --makeopts=-j${CORES} all"

### Tools and services
# These could be appended to.
TOOLS="" 
SERVICES="systemctl enable zfs-import boot
systemctl enable zfs-mount boot
systemctl enable zfs-share default
systemctl enable zfs-zed default"

### File systems.
FS="zfs" # "zfs", "btrfs"
LUKS="" # "1", "2", anything else means no LUKS encryption

case "$FS" in
    btrfs) ;;
    zfs) PACKAGE_USE="${PACKAGE_USE}
>=sys-apps/util-linux-2.30.2 static-libs"
         GENKERNEL="${GENKERNEL} --no-zfs; ${EMERGE} sys-fs/zfs sys-fs/zfs-kmod; ${GENKERNEL} --zfs; genkernel initframfs"
         ACCEPT_KEYWORDS="sys-kernel/spl ~amd64
sys-fs/zfs ~amd64
sys-fs/zfs-kmod ~amd64"
         SERVICES="${SERVICES} \
systemctl enable zfs.target
systemctl enable zfs-import-cache \
systemctl enable zfs-mount \
systemctl enable zfs-import.target \
systemctl enable zfs-zed";;
esac

#### Encryption
[ -z "$ENCRYPT" ] && PACKAGEUSE="${PACKAGEUSE}
sys-apps/systemd gnuefi cryptsetup
sys-fs/cryptsetup luks1_default
sys-kernel/dracut systemd device-mapper"

#### Bootloader
case "$BOOTLOADER" in
    efistub) install_bootloader () {
                 dir=$(pwd)
                 mkdir --parents /boot/EFI/Gentoo/
                 IMAGE=$(ls /boot/ | grep vmlinuz.*gentoo.*x86_64$)
                 cp  /boot/$IMAGE /boot/EFI/Gentoo/bootx64.efi
                 INITRAMFS=$(ls /boot/ | grep initramfs.*gentoo.*x86_64.img$)
                 cp /boot/$INITRAMFS /boot/EFI/Gentoo/initramfs
                 efibootmgr --disk $EFI_DISK --part ${EFI_PARTITION: -1} --create --label "Gentoo" --loader "\EFI\Gentoo\bootx64.efi" --unicode "dozfs=cache root=ZFS=zroot/gentoo initrd=\EFI\Gentoo\initramfs"
             } ;;
    systemd) install_bootloader () {
		dir=$(pwd)
		IMAGE=$(ls /boot/ | grep vmlinuz.*gentoo.*x86_64$)
		INITRAMFS=$(ls /boot/ | grep initramfs.*gentoo.*x86_64.img$)
		bootctl --path=/boot install
		echo "title	Gentoo Linux
linux	/$IMAGE
initrd	/$INITRAMFS
options dozfs=cache zfs=ZFS=zroot/gentoo" > /boot/loader/entries/gentoo.conf
             };
    grub2)  ;;
esac
