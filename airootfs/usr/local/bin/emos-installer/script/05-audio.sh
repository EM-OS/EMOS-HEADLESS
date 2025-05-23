#!/bin/bash
set -e

# Use gum to select an audio system
audio_choice=$(gum choose --header="Select audio system to install:" \
  "PipeWire (recommended)" "PulseAudio" "None")

echo "[INFO] Selected: $audio_choice"

case "$audio_choice" in
  "PipeWire (recommended)")
    echo "[INFO] Installing PipeWire..."
    # Install PipeWire and related packages
    arch-chroot /mnt pacman -S --noconfirm --needed \
      pipewire pipewire-alsa pipewire-jack pipewire-pulse \
      gst-plugin-pipewire libpulse wireplumber
    echo "[INFO] Pipwire now installed"
    ;;

  "PulseAudio" )
    echo "[INFO] Installing PulseAudio..."
    # Install PulseAudio and tools
    arch-chroot /mnt pacman -S --noconfirm --needed \
      pulseaudio alsa-utils pavucontrol
    echo "[INFO] PulseAudio now installed"

    ;;

  "None")
    echo "[INFO] No audio packages will be installed."
    ;;

  *)
    echo "[ERROR] Invalid selection."
    exit 1
    ;;
esac

echo "[INFO] Audio setup complete."


