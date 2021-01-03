# Customize everything before the 'Ignore' comment.
# Alias.
alias cp="cp -v"
alias mv="mv -v"
alias rm="rm -v"
alias emerge="emerge --ask=n"
# Shell variable.
BOOTLOADER="systemd-boot" # "efistub" "systemd-boot"
CORES=4
EDITOR="vi" 
EFI_DISK="/dev/nvme0n1"
EFI_PARTITION="p1"
FS="zfs" # "zfs" # Root filesystem, options needed for dependencies and services.
INIT="systemd" "systemd"
MAKE_CONF="EMERGE_DEFAULT_OPTS=\"--ask --keep-going --jobs ${CORES} --load-average ${CORES}.0\"
FEATURES=\"parallel-fetch parallel-install\"
MAKEOPTS=\"-j4 -l4\"
USE=\"systemd threads -gui -sound\" # savedconfig does not currently work for sys-kernel/linux-firmware"
KERNEL_RAMDISKOPTS="--firmware --compress-initramfs --microcode-initramfs"
TOOLS="cronie dosfstools dhcpcd gentoolkit"
SERVICES="zfs.target zfs-import-cache  zfs-mount zfs-import.target zfs-share zfs-zed"
# Functions.
KERNEL_INSTALL() { genkernel --makeopts=-j{cores} all }
# Hooks.
KERNEL_ENTER_HOOK=""
KERNEL_EXIT_HOOK=""
}
# Ignore.
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
			cd /usr/src/linux
			# Write sed commands to active options.
			genkernel --zfs
			emerge sys-fs/zfs sys-fs/zfs-kmod # ZFS needs to be reinstalled after every kernel compile.
			zgenhostid
		}
		KERNEL_EXIT_HOOK="$KERNEL_EXIT_HOOK KERNEL_ZFS" ;;
esac
