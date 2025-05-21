#!/bin/bash
disk=$(gum input --placeholder "/dev/sda" --prompt "Enter the disk to partition (e.g., /dev/sda):")
if gum confirm "WARNING: This will erase all data on $disk. Continue?"; then
  parted "$disk" --script mklabel gpt
  parted "$disk" --script mkpart ESP fat32 1MiB 300MiB
  parted "$disk" --script set 1 esp on
  parted "$disk" --script mkpart primary ext4 300MiB 100%
  mkfs.fat -F32 "${disk}1"
  mkfs.ext4 "${disk}2"
  mount "${disk}2" /mnt
  mkdir -p /mnt/boot/efi
  mount "${disk}1" /mnt/boot/efi
  echo "$disk" > /tmp/emos_disk
fi
