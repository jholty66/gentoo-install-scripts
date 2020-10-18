#!/bin/bash
### About
# This script does not show how to partitino the disks, as that varies
# between different computers and user preferences

#### What this script does
# This script performs a minimal install of Gentoo Linux on BTRFS file
# system, with System-D and GenKernel automatically without any user
# input once it is executed.

# I choose not to use the latest Stage 3 tarball and kernel versions, as
# these have been tested and have no errors. Using the latest versions
# has the potential of creating an extra point of failure during the
# installation process.

# Similarly, Genkernel is used to both avoid manually configuring the
# kernel and to narror the points of failure when booting in the system
# for the first time. Once the system has been booted successfully,
# Genkernel can be replaced with a customized kernel configuration.

# This does not partition, format or mount the disks, that is left to
# the user or done with the script "partition-disks.sh"

#### How to use this script
# Since there is no user input required, all customizations to commands
# are set as veriables at the beginnig of the script. All customizations
# to files that would be configured with a text editor of choice would
# be done on template files found in this project root directory.

### Customizations
GITDIR=$(pwd)
DISK=/dev/nvme0n1

### Install the Stage 3 tarball
echo "Installing State 3 tarball.\n"
[ ! -d "/mnt/gentoo/root/" ] && mkdir /mnt/gentoo/root
echo -e "\nExtracting tarball.\n"
time tar xpvf $GITDIR/stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo

### Configure portage
echo -e "\nCopying partage files ..\n"
rm -rf /mnt/gentoo/etc/portage/package.use/
cp $GITDIR/package.use               /mnt/gentoo/etc/portage/
mv /mnt/gentoo/etc/portage/make.conf $GITDIR/backup
cp /etc/portage/make.conf            /mnt/gentoo/etc/portage/make.conf.def
cp $GITDIR/make.conf                 /mnt/gentoo/etc/portage/
cp $GITDIR/package.accept_keywords   /mnt/gentoo/etc/portage
cp $GITDIR/package.license           /mnt/gentoo/etc/portage

### Chroot
echo -e "\nChanging root.\n"
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
cd /mnt/gentoo
mount -t proc none proc
mount --rbind /sys sys
mount --make-rslave sys
mount --rbind /dev dev
mount --make-rslave dev
cp $GITDIR/genfstab.sh /mnt/gentoo/root/genfstab.sh
cp $GITDIR/gentoo-chroot.sh /mnt/gentoo/root/gentoo-chroot.sh
chmod +x /mnt/gentoo/root/gentoo-chroot.sh
chroot /mnt/gentoo /mnt/gentoo/root/gentoo-chroot.sh

### Finnish installation
cd /
echo ""
echo "Finnished installation. Unmount disks and reboot."
echo ""
