### Customization
DISK=/dev/nvme0n1
DISTRO=gentoo
ESPSIZE=550MiB
SUBVOLS=(gentoo gentoo/tmp gentoo/var boot home root snapshots virtual)
SUBVOLOPTIONS=ssd,noatime,compress=lzo

### Mount partitions
echo -e  "\nMounting partitions.\n"
mkdir /mnt/$DISTRO
mount -t btrfs -o $SUBVOLOPTIONS,subvol=gentoo      "${DISK}p2" /mnt/$DISTRO/
mkdir /mnt/$DISTRO/{boot,home,root,snapshots,virtual,mnt,mnt/btrfs}
mount -t btrfs -o $SUBVOLOPTIONS,subvol=home      "${DISK}p2" /mnt/$DISTRO/home     
mount -t btrfs -o $SUBVOLOPTIONS,subvol=root      "${DISK}p2" /mnt/$DISTRO/root     
mount -t btrfs -o $SUBVOLOPTIONS,subvol=snapshots "${DISK}p2" /mnt/$DISTRO/snapshots
mount -t btrfs -o $SUBVOLOPTIONS,subvol=virtual   "${DISK}p2" /mnt/$DISTRO/virtual
mount -t btrfs -o $SUBVOLOPTIONS                  "${DISK}p2" /mnt/$DISTRO/mnt/btrfs
mkdir /mnt/$DISTRO/boot
mount "${DISK}p1" /mnt/$DISTRO/boot
df
