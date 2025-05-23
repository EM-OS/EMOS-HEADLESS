#!/bin/bash

echo "Set root password:"
passwd root || { echo "Failed setting root password"; exit 1; }

# Ask username OUTSIDE chroot
username=$(gum input --placeholder "emos" --prompt "Enter new username:")

# Inside chroot: create user, set shell, add to wheel group, enable sudo
arch-chroot /mnt /bin/bash <<EOF
useradd -m -G wheel -s /bin/bash "$username"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
EOF

# Now set password for the new user OUTSIDE chroot, but on the /mnt system
echo "Set password for user $username:"
arch-chroot /mnt passwd "$username"
