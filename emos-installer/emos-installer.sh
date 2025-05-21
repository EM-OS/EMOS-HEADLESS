#!/bin/bash
set -euo pipefail

# if [[ $EUID -ne 0 ]]; then
#   echo "[INFO] Relaunching as root..."
#   exec sudo "$0" "$@"
# fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPTS_DIR="script"
log() {
  echo -e "\e[1;32m[INFO]\e[0m $*"
}

error() {
  echo -e "\e[1;31m[ERROR]\e[0m $*" >&2
  exit 1
}

run_step() {
  local step=$1
  local script_path="$SCRIPT_DIR/$SCRIPTS_DIR/$step"
  if [[ ! -x "$script_path" ]]; then
    error "Missing executable script: $script_path"
  fi
  log "Running $step..."
  "$script_path"
  log "$step completed."
}

main() {
  log "Starting EMOS Installer..."

  run_step "00-welcome.sh"
  run_step "01-partition.sh"
  run_step "02-install_base.sh"
  run_step "03-gpu-driver.sh"
  run_step "04-select_dewm.sh"
  run_step "05-install_dewm.sh"
  run_step "06-user.sh"
  run_step "07-mirrors.sh"
  run_step "08-audio.sh"
  run_step "09-packages.sh"
  run_step "10-postinstall.sh"

  log "Installation complete! You can now reboot into your new EMOS system."
}

main "$@"
