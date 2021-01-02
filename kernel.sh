# Install kernel and initramfs.
set -e
source custom.sh
emerge sys-kernel/gentoo-sources sys-kernel/genkernel linux-firmware
cd /usr/src/linux
PRE_KERNEL_HOOK
KERNEL_COMPILE
POST_KERNEL_HOOK
genkernel initramfs $KERNEL_RAMDISKOPTS
