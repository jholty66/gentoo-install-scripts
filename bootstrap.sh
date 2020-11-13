#!/bin/sh

GITDIR=$(pwd)
source $GITDIR/custom.sh

### Install tarball
echo "
Dowloading tarball.
"
latest_stage3=$(curl http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3.txt 2>/dev/null | grep stage3-amd64-systemd)
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/$latest_stage3
echo "
Extracting tarball.
"
time tar xpvf $GITDR/config/stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo

### Configure portage.
echo "
Configuring portage.
"

# package.use
[ -d "/mnt/gentoo/etc/portage/package.use/" ] && rm -rf /mnt/gentoo/etc/portage/package.use/
cp $GITDIR/package.use /mnt/gentoo/etc/portage/

# make.conf
[ -f "/etc/portage/make.conf" ] && cp /etc/portage/make.conf /mnt/gentoo/etc/portage/make.conf.def
[ -f "/mnt/gentoo/etc/portage/make.conf"] && rm /mnt/gentoo/etc/portage/make.conf
cp -f $GITDIR/make.conf /mnt/gentoo/etc/portage/
echo MAKE_CONF >> /mnt/gentoo/etc/portage/make.conf

cp $GITDR/{package.accept_keywords,package.license} /mnt/gentoo/etc/portage

### Chroot
echo "
Changing root."
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
sh mount-virtual.sh # Mounting virtual filesystems is done with a script to make manual chrooting easier.
SCRIPTS={chroot.sh,custom.sh,genfstab.sh}
cp $GITDR/$SCRIPTS /mnt/gentoo/root/
chmod +x /mnt/gentoo/root/$SCRIPTS
# chroot /mnt/gentoo/ /mnt/gentoo 
env -i HOME=/root TERM=$TERM chroot . /root/gentoo-chroot.sh
