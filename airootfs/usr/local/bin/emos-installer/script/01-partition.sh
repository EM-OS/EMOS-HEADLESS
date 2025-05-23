#!/bin/bash
set -euo pipefail

log() {
  echo -e "\e[1;32m[INFO]\e[0m $*"
}

error() {
  echo -e "\e[1;31m[ERROR]\e[0m $*" >&2
  exit 1
}

# Check if /mnt is already mounted
if mountpoint -q /mnt; then
  error "/mnt is already mounted. Please unmount before running this script."
fi

# List disks (only /dev/sd* or /dev/nvme* block devices)
disks=$(lsblk -dn -o NAME,TYPE | awk '$2=="disk" {print "/dev/" $1}')

if [[ -z "$disks" ]]; then
  error "No disks found."
fi

echo "Available disks:"
echo "$disks"

# Use gum to select disk
if ! command -v gum &>/dev/null; then
  error "gum is required but not installed."
fi

disk=$(echo "$disks" | gum choose --limit 1)

if [[ -z "$disk" ]]; then
  error "No disk selected, aborting."
fi

if gum confirm "WARNING: This will erase all data on $disk. Continue?"; then
  log "Partitioning disk $disk..."

  parted "$disk" --script mklabel gpt
  parted "$disk" --script mkpart ESP fat32 1MiB 300MiB
  parted "$disk" --script set 1 esp on
  parted "$disk" --script mkpart primary ext4 300MiB 100%
  partprobe "$disk"

  log "Formatting partitions..."
  mkfs.fat -F32 "${disk}1"
  mkfs.ext4 "${disk}2"

  log "Mounting partitions..."
  mount "${disk}2" /mnt
  mkdir -p /mnt/boot/efi
  mount "${disk}1" /mnt/boot/efi

  log "Mounting virtual filesystems for chroot..."
  mount --types proc /proc /mnt/proc
  mount --rbind /sys /mnt/sys
  mount --rbind /dev /mnt/dev
  mount --rbind /run /mnt/run

  echo "$disk" > /tmp/emos_disk

  log "Disk partitioned, formatted, and mounted successfully."
else
  log "Partitioning cancelled."
  exit 0
fi

# Function to cleanup mounts after chroot or installation
# cleanup() {
#   log "Cleaning up mounts..."
#   umount -l /mnt/run || true
#   umount -l /mnt/dev || true
#   umount -l /mnt/sys || true
#   umount -l /mnt/proc || true
#   umount -l /mnt/boot/efi || true
#   umount -l /mnt || true
#   log "Unmounted all partitions and pseudo filesystems."
# }

# Uncomment this if you want to auto-cleanup when the script exits
# trap cleanup EXIT

# Usage note:
# After running your installation steps with `arch-chroot /mnt ...`,
# call cleanup manually or enable the trap above.
