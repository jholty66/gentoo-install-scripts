alias emerge="emerge --ask=n"

BOOTLOADER="systemd-boot" # "efistub" "systemd-boot"
CORES=4
FS="zfs" # "zfs" # Root filesystem, options needed for dependencies and services.
FS_ROOT="zroot/gentoo"
GENKERNEL="genkernel --makeopts=-j$CORES all" # genkernel install command, used if not manual install
HOSTNAME="gentoo-pc" # Hostname, ignored if left blank.
INIT="systemd" # "systemd"
KERNEL_INITRAMFS="dracut" # "dracut" "genkernel" # Defaults to genkernel.
KEYMAP="uk" # Console keyboard layout.
LOCALE="en_GB" # UTF-8 only.
MARCH="native" # Leave blank to not include option.
PORTAGE_TMPFS="12G" # Size of RAM for portage tmpfs, blank to disable.
TOOLS="cronie dosfstools dhcpcd gentoolkit" # Packages installed after kernel compile.
SECURE_PASSWD="nil" # "t" "nil"
SERVICES="cronie dhcpcd"
