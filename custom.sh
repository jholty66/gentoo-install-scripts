# Alias.
alias cp="cp -v"
alias mv="mv -v"
alias rm="rm -v"
alias emerge="emerge --ask=n"
# Shell variable.
BOOTLOADER="systemd-boot" # "efistub" "systemd-boot"
CORES=4
EDITOR="vi" 
EFI_DISK="/dev/vda"
EFI_PARTITION="1"
FS="zfs" # "zfs" # Root filesystem, options needed for dependencies and services.
INIT="systemd" # "systemd"
MAKE_CONF="EMERGE_DEFAULT_OPTS=\"--ask --keep-going --jobs ${CORES} --load-average ${CORES}.0\"
FEATURES=\"parallel-fetch parallel-install\"
MAKEOPTS=\"-j4 -l4\"
USE=\"systemd threads -gui -sound\" # savedconfig does not currently work for sys-kernel/linux-firmware"
KERNEL_RAMDISKOPTS="--firmware --compress-initramfs --microcode-initramfs"
TOOLS="cronie dosfstools dhcpcd gentoolkit" # Packages installed after kernel compile.
SERVICES="cronie dhcpcd"
# Functions.
KERNEL_INSTALL() {
	genkernel --no-zfs --makeopts=-j$CORES all
}
# Hooks.
KERNEL_ENTER_HOOK=""
KERNEL_EXIT_HOOK=""
# Case statement.
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
			sed -i 's/^.*CONFIG_CRYPTO_DEFLATE*$/CONFIG_CRYPTO_DEFLATE=y/' /usr/src/linux/.config
			sed -i 's/^.*CONFIG_FORTIFY_SOURCE.*$/# CONFIG_FORTIFY_SOURCE is not set/' /usr/src/linux/.config
			genkernel --zfs
			emerge sys-fs/zfs sys-fs/zfs-kmod # ZFS needs to be reinstalled after every kernel compile.
			zgenhostid
		}
		KERNEL_EXIT_HOOK="$KERNEL_EXIT_HOOK KERNEL_ZFS;" 
		KERNEL_PARAMS="$KERNEL_PARAMS dozfs=cache zfs=zroot/gentoo rw" ;;
esac
case "$INIT" in
	systemd) KERNEL_SYSTEMD() {
			sed -i 's/^.*CONFIG_GENTOO_LINUX_INIT_SYSTEMD.*$/CONFIG_GENTOO_LINUX_INIT_SYSTEMD=y/' /usr/src/linux/.config
		} 
		KERNEL_ENTER_HOOK="$KERNEL_ENTER_HOOK KERNEL_SYSTEMD;" 
		INIT_ADD() {
			systemctl enable $@
		} ;;
esac
			
