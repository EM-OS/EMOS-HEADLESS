#!/bin/bash
set -e

# Display greeter options using gum
greeter_choice=$(gum choose --header="Select a greeter (display manager) to install:" \
  "LightDM" "GDM" "SDDM" "None")

echo "[INFO] Selected: $greeter_choice"

# Install and enable the selected greeter
if [[ "$greeter_choice" == "LightDM" ]]; then
  arch-chroot /mnt pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
  arch-chroot /mnt systemctl enable lightdm.service
  echo "[INFO] LightDM installed and enabled."

elif [[ "$greeter_choice" == "GDM" ]]; then
  arch-chroot /mnt pacman -S --noconfirm --needed gdm
  arch-chroot /mnt systemctl enable gdm.service
  echo "[INFO] GDM installed and enabled."

elif [[ "$greeter_choice" == "SDDM" ]]; then
  arch-chroot /mnt pacman -S --noconfirm --needed sddm
  arch-chroot /mnt systemctl enable sddm.service
  echo "[INFO] SDDM installed and enabled."

elif [[ "$greeter_choice" == "None" ]]; then
  echo "[INFO] No greeter will be installed."
else
  echo "[ERROR] Invalid selection."
  exit 1
fi

echo "[INFO] Greeter setup complete."
