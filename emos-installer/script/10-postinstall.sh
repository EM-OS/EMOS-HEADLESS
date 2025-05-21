#!/bin/bash
set -euo pipefail

log() {
  echo -e "\e[1;32m[INFO]\e[0m $*"
}

# Run postinstall setup inside chroot
log "Running post-install configuration..."
arch-chroot /mnt /bin/bash <<'EOF'
# Set timezone
ln -sf /usr/share/zoneinfo/$(cat /tmp/emos_timezone) /etc/localtime
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Enable networking
systemctl enable NetworkManager

# Install GRUB (UEFI)
echo "[*] Installing GRUB for UEFI..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=EMOS
grub-mkconfig -o /boot/grub/grub.cfg
EOF

# Ask user if they want to enter chroot
if gum confirm "Do you want to enter the chroot environment now for additional setup?" --default=false; then
  log "Entering chroot environment. Type 'exit' to return."
  arch-chroot /mnt /bin/bash
fi

# Ask user if they want to reboot now
if gum confirm "Do you want to reboot now?" --default=true; then
  log "Rebooting system..."
  reboot
else
  log "You can reboot the system manually later."
fi
