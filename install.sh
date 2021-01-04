set -e
source ./custom.sh
case "$FS" in
	btrfs) ;;
	zfs)
		SERVICES="$SERVICES zfs-mount zfs-share zfs-zed"
		case "$INIT" in
			openrc) SERVICES="zfs-import $SERVICES" ;;
			systemd) SERVICES="zfs.target zfs-import-cache $SERVICES zfs-import.target" ;;
		esac
		KERNEL_RAMDISKOPTS="$KERNEL_RAMDISKOPTS --zfs" 
		KERNEL_ZFS() {
			emerge sys-fs/zfs sys-fs/zfs-kmod
			# Write sed commands to active options.
			sed -i 's/^.*CONFIG_GCC_PLUGIN_RANDSTRUCT.*$/# CONFIG_GCC_PLUGIN_RANDSTRUCT is not set/' /usr/src/linux/.config
			grep "^.*CONFIG_GCC_PLUGIN_RANDSTRUCT.*$" /usr/src/linux/.config
			sed -i 's/^.*CONFIG_CRYPTO_DEFLATE*$/CONFIG_CRYPTO_DEFLATE=y/' /usr/src/linux/.config
			grep "^.*CONFIG_CRYPTO_DEFLATE*$" /usr/src/linux/.config
			sed -i 's/^.*CONFIG_FORTIFY_SOURCE.*$/# CONFIG_FORTIFY_SOURCE is not set/' /usr/src/linux/.config
			grep "^.*CONFIG_FORTIFY_SOURCE.*$" /usr/src/linux/.config
			genkernel --zfs
			emerge sys-fs/zfs sys-fs/zfs-kmod # ZFS needs to be reinstalled after every kernel compile.
			zgenhostid
		}
		KERNEL_POST_HOOK="$KERNEL_POST_HOOK KERNEL_ZFS;"
		KERNEL_PARAMS="$KERNEL_PARAMS dozfs=cache zfs=$FS_ROOT rw"
		ZFS_CACHE() {
			[ -d /mnt/gentoo/etc/zfs/ ] || mkdir /mnt/gentoo/etc/zfs/;cp /etc/zfs/zpool.cache /mnt/gentoo/etc/zfs
		}
		CHROOT_PRE_HOOK="$CHROOT_PRE_HOOK ";;
esac
case "$INIT" in
	systemd) source ./make.conf;USE="$USE gnuefi";sed -i "s/^USE.*$/USE=\"$USE\"/" make.conf 
		KERNEL_SYSTEMD() {
			sed -i 's/^.*CONFIG_GENTOO_LINUX_INIT_SYSTEMD.*$/CONFIG_GENTOO_LINUX_INIT_SYSTEMD=y/' /usr/src/linux/.config
			grep "^.*CONFIG_GENTOO_LINUX_INIT_SYSTEMD.*$" /usr/src/linux/.config
		} 
		KERNEL_PRE_HOOK="$KERNEL_PRE_HOOK KERNEL_SYSTEMD;"
		INIT_ADD() {
			systemctl enable $@
		} ;;
esac
bootstrap() { # Install and extractstage3 tarball.  Copy over config files.	
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
}
mount-virtual() {  # Mount virtual file systems.
	cd /mnt/gentoo
	mount -t proc none proc
	mount --rbind /sys sys
	mount --make-rslave sys
	mount --rbind /dev dev
	mount --make-rslave dev
	test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
	mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
	chmod 1777 /dev/shm
}
chroot() {
	eval $CHROOT_PRE_HOOK
	'set -e;source /etc/profile&&/usr/sbin/env-update&&/bin/bash' | env -i HOME=/root TERM=$TERM chroot /mnt/gentoo/ /bin/bash -s
	eval $CHROOT_POST_HOOK # This is evaluated after chrooting, not once entered the chroot environment.
}
setup-portage() {
	emerge-webrsync
	emerge --update --deep --newuse @world
}
locale() {
	echo $LOCALE > /etc/locale.gen
	locale-gen
	source /etc/profile && env-update
}
fstab() { 
	emerge app-portage/layman dev-vcs/git
	layman -L
	yes | layman -a zscheile
	emerge asciidoc
	emerge --nodeps arch-install-scripts
	cp /etc/fstab{,.bak}&&cp /etc/fstab{./def}
	genfstab -U -p / > /etc/fstab
	cat /etc/fstab
}
kernel() {# Install kernel and initramfs.
	emerge sys-kernel/gentoo-sources sys-kernel/genkernel linux-firmware
	cd /usr/src/linux
	eval $KERNEL_PRE_HOOK
	KERNEL_INSTALL
	eval $KERNEL_POST_HOOK
	genkernel initramfs $KERNEL_RAMDISKOPTS
}
services() {
	emerge $TOOLS
	INIT_ADD $SERVICES
}
bootloader() {
	IMAGE=$(ls /boot/ | grep vmlinuz.*gentoo.*x86_64$)
	INITRAMFS=$(ls /boot/ | grep initramfs.*gentoo.*x86_64.img$)
	case "$BOOTLOADER" in
		grub2) echo 'Not supported, yet.';;
		efistub) mkdir --parents /boot/EFI/Gentoo/
			cp  /boot/$IMAGE /boot/EFI/Gentoo/bootx64.efi;cp /boot/$INITRAMFS /boot/EFI/Gentoo/initramfs
			efibootmgr --disk $EFI_DISK --part ${EFI_PARTITION: -1} --create --label "Gentoo" --loader "\EFI\Gentoo\bootx64.efi" --unicode $KERNEL_PARAMS ;;
		systemd-boot) bootctl --path=/boot install
			echo "title	Gentoo Linux
linux	/$IMAGE
initrd	/$INITRAMFS
options	$KERNEL_PARAMS" > /boot/loader/entries/gentoo.conf
			cat /boot/loader/entries/gentoo.conf;;
	esac
}
all() {
	bootstrap&&mount-virtual
	eval $CHROOT_PRE_HOOK
	echo 'locale&&kernel&&services&&bootloader' | env -i HOME=/root TERM=$TERM chroot /mnt/gentoo/ /bin/bash -s
	eval $CHROOT_POST_HOOK
}
while true; do
	case "$1" in
		--help) cat README;break;;
		--bootstrap) bootstrap();shift;;
		--mount) mount-virtual();shift;;
		--chroot) chroot();shift;;
		--setup) setup-portage();shift;;
		--locale) locale();shift;;
		--fstab) fstab();shift;;
		--kernel) kernel();shift;;
		--services) services();shift;;
		--bootloader) bootloader();shift;;
		--all) all();break;;
		--) shift;break;
		*) break;;
	esac
	shift
done
