#!/usr/bin/env bash
# A customizable script to boot Arch ISO or disk image using QEMU with UEFI or BIOS

set -eu

print_help() {
  cat <<EOF
Usage:
    run_archiso [options]

Options:
    -a              set accessibility support using brltty
    -b              set boot type to 'BIOS' (default)
    -d              set image type to hard disk instead of optical disc
    -h              print help
    -i [image]      ISO image to boot into
    -s              use Secure Boot (only relevant when using UEFI)
    -u              set boot type to 'UEFI'
    -v              use VNC display (instead of default SDL)
    -c [image]      attach an additional optical disc image (e.g. cloud-init)
    --disk [img]    attach a virtual hard disk image (e.g. for installs)
    -g [res]        set VGA resolution (default std)
    -t [title]      set window name/title

Example:
    ./run_archiso.sh -u -i myos.iso --disk myos.img -t "MyOS VM"
EOF
}

cleanup_working_dir() {
  [[ -d "$working_dir" ]] && rm -rf -- "$working_dir"
}

copy_ovmf_vars() {
  [[ -f /usr/share/edk2/x64/OVMF_VARS.4m.fd ]] || {
    echo "ERROR: OVMF_VARS.4m.fd not found. Install edk2-ovmf." >&2
    exit 1
  }
  cp -av /usr/share/edk2/x64/OVMF_VARS.4m.fd "$working_dir/"
}

check_image() {
  [[ -n "$image" && -f "$image" ]] || {
    echo "ERROR: ISO image not found: $image" >&2
    exit 1
  }
}

run_image() {
  if [[ "$boot_type" == "uefi" ]]; then
    copy_ovmf_vars
    local ovmf_code="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
    [[ "$secure_boot" == "on" ]] && ovmf_code="/usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd"
    qemu_options+=(
      -drive "if=pflash,format=raw,readonly=on,file=$ovmf_code"
      -drive "if=pflash,format=raw,file=${working_dir}/OVMF_VARS.4m.fd"
    )
  fi

  [[ "$accessibility" == "on" ]] && qemu_options+=(
    -chardev braille,id=brltty
    -device usb-braille,id=usbbrl,chardev=brltty
  )

  [[ -n "$oddimage" ]] && qemu_options+=(
    -device scsi-cd,bus=scsi0.0,drive=cdrom1
    -drive id=cdrom1,if=none,format=raw,media=cdrom,readonly=on,file=$oddimage
  )

  [[ -n "$disk_image" ]] && qemu_options+=(
    -drive file=$disk_image,format=raw,if=virtio
  )

  qemu-system-x86_64 \
    -m 4096 -smp 2 -enable-kvm -cpu host \
    -boot d \
    -cdrom "$image" \
    -vga ${vga} \
    -display ${display} \
    -serial stdio \
    -netdev user,id=net0,hostfwd=tcp::60022-:22 \
    -device virtio-net-pci,netdev=net0 \
    -name "${title}" \
    "${qemu_options[@]}"
}

# Defaults
image=''
oddimage=''
disk_image=''
accessibility=''
boot_type='bios'
secure_boot='off'
display='sdl'
vga='std'
title='archiso'
qemu_options=()
working_dir="$(mktemp -dt run_archiso.XXXXXXXXXX)"
trap cleanup_working_dir EXIT

# Parse args
while (( $# )); do
  case "$1" in
    -a) accessibility='on'; shift;;
    -b) boot_type='bios'; shift;;
    -u) boot_type='uefi'; shift;;
    -s) secure_boot='on'; shift;;
    -d) mediatype='hd'; shift;;
    -i) image="$2"; shift 2;;
    -c) oddimage="$2"; shift 2;;
    -v) display='none'; qemu_options+=( -vnc :0 ); shift;;
    --disk) disk_image="$2"; shift 2;;
    -g) vga="$2"; shift 2;;
    -t) title="$2"; shift 2;;
    -h|--help) print_help; exit 0;;
    *) echo "Unknown option: $1"; print_help; exit 1;;
  esac
done

check_image
run_image
