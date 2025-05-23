#!/bin/bash
set -euo pipefail

# Fetch remote package list (e.g., from GitHub Raw URL)
REMOTE_PKG_LIST="https://raw.githubusercontent.com/EM-OS/EMOS-PACKAGES/refs/heads/main/packages.txt"
# REMOTE_PKG_LIST="https://raw.githubusercontent.com/EM-OS/EMOS-PACKAGES/main/all-packages.txt"

# Download the list and extract package names
AVAILABLE_PKGS=$(curl -s "$REMOTE_PKG_LIST" | grep -v '^#' | tr '\n' ' ')

if [[ -z "$AVAILABLE_PKGS" ]]; then
  echo "Error: Could not fetch remote package list."
  exit 1
fi

# Pretty print the list one per line so it wraps nicely
echo "Available packages:"
echo "$AVAILABLE_PKGS" | tr ' ' '\n' | pr -3 -t

# Allow user to search and select packages using Gum's input and choose
search_input=$(gum input --placeholder "Type a package name to search (or leave blank to list all)")

if [[ -n "$search_input" ]]; then
  # Filter the available packages based on the search input
  filtered_pkgs=$(echo "$AVAILABLE_PKGS" | tr ' ' '\n' | grep -i "$search_input" | tr '\n' ' ')
else
  # No input, list all packages
  filtered_pkgs=$AVAILABLE_PKGS
fi

if [[ -z "$filtered_pkgs" ]]; then
  echo "No matching packages found for your search."
  exit 0
fi

# Let user choose multiple packages from the filtered list
extras=$(gum choose --no-limit $filtered_pkgs)

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
