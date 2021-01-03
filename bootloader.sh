set -e
source ./custom.sh
IMAGE=$(ls /boot/ | grep vmlinuz.*gentoo.*x86_64$)
INITRAMFS=$(ls /boot/ | grep initramfs.*gentoo.*x86_64.img$)
case "$BOOTLOADER" in
	grub2) echo 'Not supported, yet.';;
	efistub) mkdir --parents /boot/EFI/Gentoo/
		cp  /boot/$IMAGE /boot/EFI/Gentoo/bootx64.efi
		cp /boot/$INITRAMFS /boot/EFI/Gentoo/initramfs
		efibootmgr --disk $EFI_DISK --part ${EFI_PARTITION: -1} --create --label "Gentoo" --loader "\EFI\Gentoo\bootx64.efi" --unicode $KERNEL_PARAMS ;;
	systemd-boot) bootctl --path=/boot install
		echo "title	Gentoo Linux
linux	/$IMAGE
initrd	/$INITRAMFS
options	$KERNEL_PARAMS" > /boot/loader/entries/gentoo.conf
		cat /boot/loader/entries/gentoo.conf;;
esac
