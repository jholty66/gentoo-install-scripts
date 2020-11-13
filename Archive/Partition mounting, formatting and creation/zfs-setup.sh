#!/bin/sh
DISK=/dev/nvme0n1
mkfs.vfat ${DISK}p1

zpool create \
      -o ashift=12 \
      -O encryption=aes-256-gcm \
      -O keylocation=prompt -O keyformat=passphrase \
      -O acltype=posixacl -O canmount=off -O compression=lz4 \
      -O dnodesize=auto -O normalization=formD -O relatime=on \
      -O xattr=sa -O mountpoint=nome \
      tank ${DISK}p2

zfs create -o mountpoint=none tank/boot
zfs create -o mountpoint=none tank/gentoo
zfs create -o mountpoint=none tank/home
zfs create -o mountpoint=none tank/root
zfs create -o mountpoint=none tank/snapshots
zfs create -o mountpoint=none tank/virtual
