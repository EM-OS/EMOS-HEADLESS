#!/bin/bash
set -euo pipefail

# Let user choose multiple packages
extras=$(gum choose --no-limit "firefox" "chromium" "vlc" "gimp")

# Save selections for record
echo "$extras" > /tmp/emos_extras

if [[ -z "$extras" ]]; then
  echo "No extra packages selected. Skipping installation."
  exit 0
fi

echo "You selected: $extras"

# Filter out already installed packages
to_install=()
for pkg in $extras; do
  if ! arch-chroot /mnt pacman -Qq "$pkg" &>/dev/null; then
    to_install+=("$pkg")
  else
    echo "Package '$pkg' is already installed, skipping."
  fi
done

if [[ ${#to_install[@]} -eq 0 ]]; then
  echo "All selected packages are already installed. Nothing to do."
  exit 0
fi

echo "Installing packages: ${to_install[*]}"
arch-chroot /mnt pacman -S --noconfirm "${to_install[@]}"
