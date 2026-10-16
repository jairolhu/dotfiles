#!/bin/bash

sudo pacman -Syu

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
sudo pacman --noconfirm -S xorg lightdm lightdm-gtk-greeter xfce4 xfce4-goodies \
               alacritty git fastfetch firefox pipewire lib32-pipewire pipewire-pulse \
	             pipewire-alsa pipewire-jack wireplumber pavucontrol yay-bin \
               xdg-user-dirs zsh gvfs-mtp gvfs-gphoto2 calibre iw \
               qbittorrent bc mpd ncmpcpp ntp cron adobe-source-han-sans-jp-fonts \
               adobe-source-han-serif-jp-fonts r rstudio-desktop timeshift ibus-mozc \
               peazip rsync wget network-manager-applet fuse2 ntfs-3g mpv gparted \
               yt-dlp shotcut syncthing easytag libreoffice-fresh noto-fonts-cjk anki \
               vulkan-intel lib32-vulkan-intel ffmpeg appimagelauncher fastfetch \
               gallery-dl os-prober mesa fooyin ifuse usbmuxd libimobiledevice \
               jdk8-openjdk exfatprogs mpc

# yay -S gtk3-patched-filechooser-icon-view glib2-patched-thumbnailer papirus-icon-theme-git \
	 ibus-autostart jdownloader2 qdirstat-bin ttf-sil-fonts

# qtile
sudo pacman -S qtile lxappearance htop python-psutil ranger feh flameshot python-iwlib rofi xdg-desktop-portal xdg-desktop-portal-gtk picom networkmanager-dmenu gsimplecal mousepad xfce4-screenshooter xfce4-taskmanager

# yay -S nitrogen qtile-extras python-aiohttp ttf-sil-fonts

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
sudo rsync -a /home/jairo/dotfiles/.jd/cfg /home/jairo/.jd/cfg

