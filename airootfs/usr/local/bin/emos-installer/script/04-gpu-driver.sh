#!/bin/bash
set -e

# Gum-based GPU driver selection
driver=$(gum choose "NVIDIA (proprietary)" "NVIDIA (open)" "AMD" "Intel" "Skip")
echo "$driver" > /tmp/emos_gpu

# Updating keyring and clearing cache to avoid PGP signature issues
echo "[INFO] Updating Arch Linux keyring and clearing cache..."
arch-chroot /mnt /bin/bash <<EOF
pacman -Sy --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman -Scc --noconfirm
EOF

# GPU driver installation
arch-chroot /mnt /bin/bash <<EOF
case "$driver" in
  "NVIDIA (proprietary)")
    echo "[INFO] Installing NVIDIA proprietary drivers..."
    pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
    ;;
  "NVIDIA (open)")
    echo "[INFO] Installing NVIDIA open-source drivers..."
    pacman -S --noconfirm nvidia-open-dkms nvidia-utils nvidia-settings
    ;;
  "AMD")
    echo "[INFO] Installing AMD drivers..."
    pacman -S --noconfirm mesa vulkan-radeon libva-mesa-driver xf86-video-amdgpu
    ;;
  "Intel")
    echo "[INFO] Installing Intel drivers..."
    pacman -S --noconfirm mesa vulkan-intel libva-intel-driver libva-utils xf86-video-intel
    ;;
  "Skip")
    echo "[INFO] Skipping GPU driver installation."
    ;;
  *)
    echo "[ERROR] Invalid selection. Exiting."
    exit 1
    ;;
esac
EOF

echo "[INFO] GPU driver installation process complete."
