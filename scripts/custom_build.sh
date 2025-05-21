#!/bin/bash

airootfs="../airootfs/etc"

# Ensure target directories exist
# mkdir -p "$airootfs"

# Grub
mkdir -p "$airootfs/default"
cp -r "/etc/default/grub" "$airootfs/default"

# Change os-release branding
cp "/usr/lib/os-release" "$airootfs"
sed -i 's/NAME=".*"/NAME="EMOS Linux"/' "$airootfs/os-release"
sed -i 's/PRETTY_NAME=".*"/PRETTY_NAME="EMOS Linux"/' "$airootfs/os-release"
sed -i 's/ID=.*/ID=emos/' "$airootfs/os-release"
sed -i 's/ID_LIKE=.*/ID_LIKE=archlinux/' "$airootfs/os-release"



# Enable sudo for wheel group
mkdir -p "$airootfs/sudoers.d"
echo "%wheel ALL=(ALL:ALL) ALL" > "$airootfs/sudoers.d/wheel"

# Enable NetworkManager (headless networking)
mkdir -p "$airootfs/systemd/system/multi-user.target.wants"
ln -sf "/usr/lib/systemd/system/NetworkManager.service" "$airootfs/systemd/system/multi-user.target.wants"

mkdir -p "$airootfs/systemd/system/network-online.target.wants"
ln -sf "/usr/lib/systemd/system/NetworkManager-wait-online.service" "$airootfs/systemd/system/network-online.target.wants"


ln -sf /usr/lib/systemd/system/sshd.service "$airootfs/systemd/system/multi-user.target.wants"
ln -sf /usr/lib/systemd/system/systemd-timesyncd.service "$airootfs/systemd/system/multi-user.target.wants"

mkdir -p "$airootfs/etc/systemd/system/getty@tty1.service.d"
cat > "$airootfs/etc/systemd/system/getty@tty1.service.d/override.conf" <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM
EOF

# Set hostname
echo "emos" > "$airootfs/hostname"

# GRUB cfg changes
grubcfg="../grub/grub.cfg"
if [ -f "$grubcfg" ]; then
    sed -i 's/default=archlinux/default=emos/' "$grubcfg"
    sed -i 's/timeout=15/timeout=10/' "$grubcfg"
    sed -i 's/menuentry "Arch/menuentry "EMOS/' "$grubcfg"

    if ! grep -q "cow_spacesize=10G copytoram=n" "$grubcfg"; then
        sed -i 's/archisosearchuuid=%ARCHISO_UUID%/archisosearchuuid=%ARCHISO_UUID% cow_spacesize=10G copytoram=n/' "$grubcfg"
    fi

    if ! grep -q "#play" "$grubcfg"; then
        sed -i 's/play/#play/' "$grubcfg"
    fi
fi

# EFI bootloader entries (branding)
efiloader="../efiboot/loader"
if [ -d "$efiloader" ]; then
    sed -i 's/Arch/EMOS/' "$efiloader/entries/01-archiso-x86_64-linux.conf"
    sed -i 's/Arch/EMOS/' "$efiloader/entries/02-archiso-x86_64-speech-linux.conf"

    sed -i 's/timeout 15/timeout 10/' "$efiloader/loader.conf"
    sed -i 's/beep on/beep off/' "$efiloader/loader.conf"
fi
