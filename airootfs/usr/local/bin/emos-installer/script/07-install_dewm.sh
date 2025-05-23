#!/bin/bash
de=$(cat /tmp/emos_de)
arch-chroot /mnt /bin/bash <<EOF
case "$de" in
  "Awesome") pacman -S --noconfirm awesome alacritty xorg-init xorg-xrandr xterm feh slock terminus-font gnu-free-fonts ttf-liberation xsel ;;
  "Bspwm") pacman -S --noconfirm bspwm sxhkd demenu xdo rxvt-unicode ;;
  "Budgie") pacman -S --noconfirm materia-gtk-theme budgie mate-terminal nemo papirus-icon-theme ;;
  "Gnome") pacman -S --noconfirm gnome gnome-tweaks ;;
  "Hyprland") pacman -S --noconfirm hyprland dunst kitty uwsm dolphin wofi xdg-desktop-portal-hyprland qt5-wayland qt6-wayland polkit-kde-agent grim slurp waybar ;;
  "I3") pacman -S --noconfirm i3-wm i3lock i3status i3blocks xss-lock xterm dmenu ;;
  "Plasma") pacman -S --noconfirm plasma-meta konsole kate dolphin ark plasma-workspace ;;
  "Xfce4") pacman -S --noconfirm xfce4 xfce4-goodies pavucontrol gvfs xarchiver ;;

esac
EOF
