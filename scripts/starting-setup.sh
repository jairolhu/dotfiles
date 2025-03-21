#!/bin/bash

sudo pacman -Syu

# AUR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sri
cd ..

# Chaotic AUR
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

sudo tee -a /etc/pacman.conf << EOF > /dev/null

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

# Actualizar pacman
sudo pacman -Syu

# Instalar programas esenciales
sudo pacman -S xorg lightdm lightdm-gtk-greeter xfce4 xfce4-goodies \
               alacritty git neofetch firefox rofi pulseaudio pavucontrol \
               htop xdg-user-dirs zsh gvfs-mtp gvfs-gphoto2 calibre \
               qbittorrent bc mpd ncmpcpp ntp cron adobe-source-han-sans-jp-fonts \
               adobe-source-han-serif-jp-fonts r rstudio-desktop timeshift ibus-mozc \
               p7zip-gui rsync wget network-manager-applet fuse2 ntfs-3g mpv gparted \
               yt-dlp shotcut syncthing easytag libroffice-fresh jdownloader2 \
               noto-fonts-cjk anki vulkan-intel ffmpeg appimagelauncher \
               simplescreenrecorder fastfetch p7zip-gui
# yay -S gtk3-patched-filechooser-icon-view glib2-patched-thumbnailer papirus-icon-theme-git ibus-autostart

# qtile
# sudo pacman -S qtile nitrogen lxappearance htop python-psutil ranger feh flameshot pcmanfn-gtk3 python-iwlib

xdg-user-dirs-update
systemctl enable lightdm

# Horario
timedatectl set-timezone America/Mexico_City
timedatectl set-ntp true
systemctl restart systemd-timesyncd

# Mover archivos de configuración
sudo rsync -a /home/jairo/dotfiles/.config /home/jairo
sudo rsync -a /home/jairo/dotfiles/.icons /home/jairo
sudo rsync -a /home/jairo/dotfiles/.oh-my-zsh  /home/jairo
sudo rsync -a /home/jairo/dotfiles/.zshrc /home/jairo
sudo rsync -a /home/jairo/dotfiles/xfce4-genmon-scripts /home/jairo
sudo rsync -a /home/jairo/dotfiles/usr/share/fonts/ /usr/share/fonts
