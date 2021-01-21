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
HOSTNAME="gentoo-pc" # Hostname, ignored if left blank.
INIT="systemd" # "systemd"
KERNEL_INITRAMFS="dracut" # "dracut" "genkernel" # Defaults to genkernel.
KEYMAP="uk" # Console keyboard layout.
LOCALE="en_GB" # UTF-8 only.
MARCH="native" # Leave blank to not include option.
PORTAGE_TMPFS="13G" # Size of RAM, blank to disable. https://wiki.gentoo.org/wiki/Portage_TMPDIR_on_tmpfs#:~:text=When%20emerging%20packages%20it%20is,and%20reduces%20HDD%2FSSD%20wear.
TOOLS="cronie dosfstools dhcpcd gentoolkit" # Packages installed after kernel compile.
SECURE_PASSWD="t" # "t" "nil"
SERVICES="cronie dhcpcd"
# Hooks.
CHROOT_PRE_HOOK=""
CHROOT_POST_HOOK=""
KERNEL_PRE_HOOK=""
KERNEL_POST_HOOK=""
