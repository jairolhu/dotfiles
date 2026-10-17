#!/bin/bash

# Enable multilib (needed for the lib32-* packages)
sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf

sudo pacman -Syu

sudo pacman -S xorg

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
sudo pacman -Syyu

# Instalar programas esenciales
sudo pacman --noconfirm -S lightdm lightdm-gtk-greeter qtile qtile-extras \
               alacritty git fastfetch firefox pipewire lib32-pipewire pipewire-pulse \
	             pipewire-alsa pipewire-jack wireplumber pavucontrol \
               xdg-user-dirs zsh gvfs-mtp gvfs-gphoto2 calibre iw \
               bc mpd ncmpcpp adobe-source-han-sans-jp-fonts \
               adobe-source-han-serif-jp-fonts r ibus-mozc \
               peazip rsync wget network-manager-applet fuse2 ntfs-3g mpv gparted \
               yt-dlp noto-fonts-cjk \
               vulkan-intel lib32-vulkan-intel ffmpeg \
               gallery-dl os-prober mesa fooyin ifuse usbmuxd \
               jdk8-openjdk exfatprogs mpc lxappearance htop python-psutil ranger \
               feh python-iwlib rofi xdg-desktop-portal xdg-desktop-portal-gtk \
               picom networkmanager-dmenu gsimplecal mousepad xfce4-screenshooter xfce4-taskmanager \
               xfce4-clipman-plugin yay-git downgrade

# Bloat not needed for tests
# sudo pacman --noconfirm -S qbittorrent cron timeshift shotcut syncthing easytag libreoffice-fresh anki rstudio-desktop

# do i really need these?
# yay -S gtk3-patched-filechooser-icon-view glib2-patched-thumbnailer papirus-icon-theme-git \

# ok, but i want to become independent from yay
# yay -S jdownloader2 qdirstat-bin ttf-sil-fonts appimagelauncher

# i really need these
yay -S nitrogen python-aiohttp ttf-sil-fonts ibus-autostart

xdg-user-dirs-update
systemctl enable lightdm

# Horario
timedatectl set-timezone America/Mexico_City
timedatectl set-ntp true
systemctl restart systemd-timesyncd
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Mover archivos de configuración
sudo rsync -a /home/jairo/dotfiles/.config /home/jairo
sudo rsync -a /home/jairo/dotfiles/.local /home/jairo
sudo rsync -a /home/jairo/dotfiles/.icons /home/jairo
sudo rsync -a /home/jairo/dotfiles/xfce4-genmon-scripts /home/jairo
sudo rsync -a /home/jairo/dotfiles/usr/share/fonts/ /usr/share/fonts
sudo rsync -a /home/jairo/dotfiles/etc/environment /etc
#sudo rsync -a /home/jairo/dotfiles/.jd/cfg /home/jairo/.jd/cfg

