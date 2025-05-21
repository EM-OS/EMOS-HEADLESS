#!/bin/bash
set -e

audio_choice=$(gum choose --header="Select audio system to install:" \
  "PipeWire (recommended)" "PulseAudio" "None")

echo "[INFO] Selected: $audio_choice"

if [[ "$audio_choice" == "PipeWire (recommended)" ]]; then
  arch-chroot /mnt pacman -S --noconfirm --needed pipewire pipewire-alsa pipewire-jack \
  pipewire-pulse gst-plugin-pipewire libpulse wireplumber

  arch-chroot /mnt systemctl enable wireplumber.service

elif [[ "$audio_choice" == "PulseAudio" ]]; then
  arch-chroot /mnt pacman -S --noconfirm --needed \
    pulseaudio alsa-utils pavucontrol

elif [[ "$audio_choice" == "None" ]]; then
  echo "[INFO] No audio packages will be installed."
else
  echo "[ERROR] Invalid selection."
  exit 1
fi

echo "[INFO] Minimal audio setup complete."
