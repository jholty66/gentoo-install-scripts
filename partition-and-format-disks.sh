#!/bin/sh
### About
# Create a partition table for an unencrypted BTRFS file sytem plus an
# EFI system partition.

### Customization
DISK=/dev/nvme0n1
DISTRO=gentoo
ESPSIZE=550MiB
SUBVOLS=(gentoo gentoo/tmp gentoo/var home root snapshots virtual)
SUBVOLOPTIONS=ssd,noatime,compress=lzo

### Partiton disk
echo "Partitoning disks ..."
sgdisk --zap-all $DISK
sgdisk --clear \
       --new=1:0:$ESPSIZE --typecode=1:ef00 \
       --new=2:0:0        --typecode=2:8200 \
       $DISK

### Format partitions
echo "Formatting partitions ..."
mkfs.vfat "${DISK}p1"
mkfs.btrfs -f "${DISK}p2"

### Create BTRFS subvolumes
echo "$Creating BTRFS subvolumes"
mkdir /mnt/btrfs
mount -t btrfs -o $SUBVOLOPTIONS "${DISK}p2" /mnt/btrfs
cd /mnt/btrfs
for i in "${SUBVOLS[@]}"; do
    btrfs subvolume create $i
done
umount /mnt/btrfs

echo "Done."
