cd /mnt/gentoo
mount -t proc none proc
mount --rbind /sys sys
mount --make-rslave sys
mount --rbind /dev dev
mount --make-rslave dev
chroot /mnt/gentoo /bin/bash
