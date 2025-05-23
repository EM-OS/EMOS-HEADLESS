#!/bin/bash
set -euo pipefail

# Uncomment if root privileges are required
# if [[ $EUID -ne 0 ]]; then
#   echo "[INFO] Relaunching as root..."
#   exec sudo "$0" "$@"
# fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPTS_DIR="$SCRIPT_DIR/script"
ASSETS="$SCRIPT_DIR/assets"

log() {
  echo -e "\e[1;32m[INFO]\e[0m $*"
}

error() {
  echo -e "\e[1;31m[ERROR]\e[0m $*" >&2
  exit 1
}

run_step() {
  local step=$1
  local script_path="$SCRIPTS_DIR/$step"
  if [[ ! -x "$script_path" ]]; then
    error "Missing executable script: $script_path"
  fi
  log "Running $step..."
  "$script_path"
  log "$step completed."
}

main() {
  log "Starting EMOS Installer..."

  echo -e "\n"
  local emos_image="$ASSETS/EMOS.svg"
  if [[ -f "$emos_image" ]]; then
    chafa --size=90 "$emos_image"  # Adjust size as needed
  else
    error "Missing EMOS image: $emos_image"
  fi
  echo -e "\n"

  for step in \
    "00-welcome.sh" \
    "01-partition.sh" \
    "02-mirrors.sh" \
    "03-install_base.sh" \
    "04-gpu-driver.sh" \
    "05-audio.sh" \
    "06-select_dewm.sh" \
    "07-install_dewm.sh" \
    "08-greeter.sh" \
    "09-user.sh" \
    "10-basic-packages.sh"\
    "11-packages.sh" \
    "12-postinstall.sh"; do
    run_step "$step"
  done

  log "Installation complete! You can now reboot into your new EMOS system."
}

main "$@"
