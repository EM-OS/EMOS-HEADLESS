#!/bin/bash
gum style --border double --margin "1 2" --padding "1 2"   --border-foreground 99 "Welcome to EMOS Linux Installer"

hostname=$(gum input --placeholder "emos-pc" --prompt "Enter hostname:")
timezone=$(gum input --placeholder "America/New_York" --prompt "Enter timezone (e.g., America/New_York):")

echo "$hostname" > /tmp/emos_hostname
echo "$timezone" > /tmp/emos_timezone
