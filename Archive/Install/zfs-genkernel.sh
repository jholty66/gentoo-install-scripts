genkernel --menuconfig --makeopts=-j4 --zfs all
emerge --ask sys-fs/zfs sys-fs/zfs-kmod sys-kernel/spl
genkernel initramfs


