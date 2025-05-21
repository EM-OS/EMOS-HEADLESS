#!/usr/bin/env bash
set -eu

IMG=""
UEFI="off"
SECURE_BOOT="off"
DISPLAY_TYPE="gtk"
VM_TITLE="Disk Image VM"

print_help() {
  cat <<EOF
Usage: $0 [options]

Options:
  -i [img]        Disk image to boot (raw format) (required)
  -u              Boot using UEFI (default: BIOS)
  -s              Enable Secure Boot (UEFI only)
  -v              Use VNC display (default: GTK)
  -t [title]      Set VM window title (default: "Disk Image VM")
  -h              Show this help message

Example:
  Boot a raw disk image with BIOS:
    $0 -i emos-test.img

  Boot with UEFI firmware:
    $0 -i emos-test.img -u

  Boot with UEFI and Secure Boot enabled:
    $0 -i emos-test.img -u -s

  Boot with VNC display and custom window title:
    $0 -i emos-test.img -v -t "EMOS VM"
EOF
}

while getopts 'i:usvt:h' flag; do
  case "$flag" in
    i) IMG="$OPTARG" ;;
    u) UEFI="on" ;;
    s) SECURE_BOOT="on" ;;
    v) DISPLAY_TYPE="none" ;;
    t) VM_TITLE="$OPTARG" ;;
    h) print_help; exit 0 ;;
    *) print_help; exit 1 ;;
  esac
done

if [[ -z "$IMG" ]]; then
  echo "ERROR: No disk image provided. Use -i"
  exit 1
fi

QEMU_OPTS=(
  -enable-kvm
  -m 4096
  -smp 2
  -cpu host
  -drive file="$IMG",format=raw,if=virtio
  -netdev user,id=net0,hostfwd=tcp::60022-:22
  -device virtio-net-pci,netdev=net0
  -vga std
  -serial stdio
  -name "$VM_TITLE"
)

if [[ "$DISPLAY_TYPE" == "none" ]]; then
  QEMU_OPTS+=(-display none -vnc :0)
else
  QEMU_OPTS+=(-display gtk)
fi

if [[ "$UEFI" == "on" ]]; then
  VARS="$(mktemp)"
  cp /usr/share/edk2/x64/OVMF_VARS.4m.fd "$VARS"

  if [[ "$SECURE_BOOT" == "on" ]]; then
    CODE="/usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd"
  else
    CODE="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
  fi

  QEMU_OPTS+=(
    -drive if=pflash,format=raw,readonly=on,file="$CODE"
    -drive if=pflash,format=raw,file="$VARS"
  )
fi

exec qemu-system-x86_64 "${QEMU_OPTS[@]}"
