#!/bin/bash
set -euo pipefail

log() {
  echo -e "\e[1;34m[INFO]\e[0m $*"
}

log "Installing base packages with pacstrap..."

pacstrap /mnt \
  base linux linux-firmware \
  sudo networkmanager \
  grub efibootmgr \
  bash-completion \
  openssh \
  vim \
  man-db man-pages \
  base-devel \
  dosfstools ntfs-3g exfat-utils \
  udisks2 smartmontools htop acpi git \
  ufw archlinux-keyring reflector \
  open-vm-tools xf86-input-vmmouse xf86-video-vmware xf86-video-qxl spice-vdagent
\

log "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

log "Setting hostname..."
cp /tmp/emos_hostname /mnt/etc/hostname

log "Base install complete."

