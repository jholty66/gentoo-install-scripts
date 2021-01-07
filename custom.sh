# Alias.
alias cp="cp -v"
alias mv="mv -v"
alias rm="rm -v"
alias emerge="emerge --ask=n"
alias grep="grep --color=auto"
# Shell variable.
BOOTLOADER="systemd-boot" # "efistub" "systemd-boot"
CORES=4
FS="zfs" # "zfs" # Root filesystem, options needed for dependencies and services.
FS_ROOT="zroot/gentoo"
INIT="systemd" # "systemd"
KERNEL_RAMDISKOPTS="--firmware --compress-initramfs --microcode-initramfs"
TOOLS="cronie dosfstools dhcpcd gentoolkit" # Packages installed after kernel compile.
SERVICES="cronie dhcpcd"
# Functions.
KERNEL_INSTALL() {
	genkernel --no-zfs --makeopts=-j$CORES all
}
# Hooks.
CHROOT_PRE_HOOK=""
CHROOT_POST_HOOK=""
KERNEL_PRE_HOOK=""
KERNEL_POST_HOOK=""
