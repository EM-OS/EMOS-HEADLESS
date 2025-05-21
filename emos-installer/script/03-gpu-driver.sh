#!/bin/bash

driver=$(gum choose "NVIDIA (proprietary)" "NVIDIA (open)" "AMD" "Intel" "Skip")

echo "$driver" > /tmp/emos_gpu

arch-chroot /mnt /bin/bash <<EOF
case "$driver" in
  "NVIDIA (proprietary)")
    pacman -S --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings
    mkinitcpio -P
    systemctl enable dkms.service
    ;;
  "NVIDIA (open)")
    pacman -S --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings
    mkinitcpio -P
    systemctl enable dkms.service
    ;;
  "AMD")
    pacman -S --noconfirm mesa vulkan-radeon libva-mesa-driver lib32-mesa lib32-vulkan-radeon xf86-video-amdgpu
    ;;
  "Intel")
    pacman -S --noconfirm mesa vulkan-intel libva-intel-driver lib32-mesa lib32-vulkan-intel xf86-video-intel
    ;;
  "Skip")
    echo "Skipping GPU driver install"
    ;;
esac
EOF
