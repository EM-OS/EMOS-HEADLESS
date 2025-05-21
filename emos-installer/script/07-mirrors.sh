#!/bin/bash
set -euo pipefail

log() {
  echo -e "\e[1;32m[INFO]\e[0m $*"
}

error() {
  echo -e "\e[1;31m[ERROR]\e[0m $*" >&2
  exit 1
}

log "Updating mirrorlist with Reflector..."

arch-chroot /mnt /bin/bash <<EOF
# Ensure reflector is installed (failsafe)
pacman -S --noconfirm --needed reflector

# Update the mirrorlist using the fastest recent HTTPS mirrors
reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Optionally enable weekly refresh of mirrors
systemctl enable reflector.timer

EOF

log "Mirrorlist updated and reflector.timer enabled."
