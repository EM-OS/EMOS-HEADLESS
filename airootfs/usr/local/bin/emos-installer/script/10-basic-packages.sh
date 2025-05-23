#!/bin/bash

# Exit on error
set -e

# URL to the package list
PACKAGE_LIST_URL="https://raw.githubusercontent.com/EM-OS/EMOS-PACKAGES/main/basic-packages.txt"

# Temporary file to store the list
TMP_FILE="/tmp/basic-packages.txt"

echo "📦 Downloading package list..."
curl -fsSL "$PACKAGE_LIST_URL" -o "$TMP_FILE"

echo "📦 Installing packages from list..."
sudo pacman -Syu --needed --noconfirm $(grep -vE '^\s*#' "$TMP_FILE" | tr '\n' ' ')

echo "✅ All packages installed successfully!"
