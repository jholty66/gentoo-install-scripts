# Install kernel and initramfs.
set -e
source ./custom.sh
emerge sys-kernel/gentoo-sources sys-kernel/genkernel linux-firmware
cd /usr/src/linux
eval $KERNEL_ENTER_HOOK
KERNEL_INSTALL
eval $KERNEL_EXIT_HOOK
genkernel initramfs $KERNEL_RAMDISKOPTS
