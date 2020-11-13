DIR=$(pwd)
cd /mnt/gentoo
mount -t proc none proc
mount --rbind /sys sys
mount --make-rslave sys
mount --rbind /dev dev
mount --make-rslave dev
cd $DIR
