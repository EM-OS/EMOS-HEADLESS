#!/bin/bash
set -euo pipefail

gum style --border double --margin "1 2" --padding "1 2" --border-foreground 99 "Welcome to EMOS Linux Installer"

REMOTE_TZ_LIST="https://raw.githubusercontent.com/EM-OS/EMOS-PACKAGES/main/timezones.txt"

# Fetch timezone list (one per line, no comments)
AVAILABLE_TZ=$(curl -s "$REMOTE_TZ_LIST" | grep -v '^#' | sed '/^\s*$/d')

if [[ -z "$AVAILABLE_TZ" ]]; then
  echo "Error: Could not fetch timezone list."
  exit 1
fi

hostname=$(gum input --placeholder "emos-pc" --prompt "Enter hostname:")

echo -e "\nType to search timezones or leave blank to list all:"
search_input=$(gum input --placeholder "e.g., America/New_York" --prompt "Search timezone:")

if [[ -n "$search_input" ]]; then
  filtered_tz=$(echo "$AVAILABLE_TZ" | grep -i "$search_input" || true)
else
  filtered_tz="$AVAILABLE_TZ"
fi

if [[ -z "$filtered_tz" ]]; then
  echo "No matching timezones found for your search."
  exit 0
fi

echo -e "\nSelect your timezone:"
timezone=$(echo "$filtered_tz" | gum choose --limit 1)

echo "You selected timezone: $timezone"
echo "$hostname" > /tmp/emos_hostname
echo "$timezone" > /tmp/emos_timezone
