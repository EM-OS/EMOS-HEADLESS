#!/bin/bash
set -euo pipefail

log() {
  echo -e "\e[1;32m[INFO]\e[0m $*"
}

error() {
  echo -e "\e[1;31m[ERROR]\e[0m $*" >&2
  exit 1
}

# Ensure /mnt is mounted
if ! mountpoint -q /mnt; then
  error "/mnt is not mounted. Cannot proceed with mirrorlist update."
fi

log "Updating mirrorlist with Reflector..."

arch-chroot /mnt /bin/bash <<'EOF'
set -euo pipefail

# Install reflector if not present
pacman -S --noconfirm --needed reflector

# Generate a fast, up-to-date mirrorlist
if ! reflector \
  --latest 10 \
  --country US,DE,FR \  # No backslash here
  --protocol https \
  --age 12 \
  --sort rate \
  --save /etc/pacman.d/mirrorlist; then
  echo -e "\e[1;33m[WARN]\e[0m Failed to update mirrors. Keeping existing mirrorlist."
fi

# Enable weekly mirror updates
systemctl enable reflector.timer
EOF

log "Mirrorlist updated and reflector.timer enabled."
