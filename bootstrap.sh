# Install and extractstage3 tarball.  Copy over config files.
set -e
source ./custom.sh
latest_stage3=$(curl http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3.txt 2>/dev/null | grep -o ^.*stage3-amd64-systemd.*\.tar\.xz)
ls | grep -o ^.*stage3-amd64-systemd.*\.tar\.xz || (wget http://distfiles.gentoo.org/releases/amd64/autobuilds/$latest_stage3 && time tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo)
[ -d "/mnt/gentoo/etc/portage/package.use/" ] && rm -rf /mnt/gentoo/etc/portage/package.use/
cp package.use /mnt/gentoo/etc/portage/
[ -f "/etc/portage/make.conf" ] && cp /etc/portage/make.conf /mnt/gentoo/etc/portage/make.conf.def
echo "${MAKE_CONF}" >> /mnt/gentoo/etc/portage/make.conf
cp {package.accept_keywords,package.license} /mnt/gentoo/etc/portage/
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
env -i HOME=/root TERM=$TERM chroot /mnt/gentoo/ /root/gentoo-installer/chroot.sh
