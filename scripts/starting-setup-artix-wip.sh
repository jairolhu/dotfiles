#!/bin/bash

sudo pacman -Syu

# Enable [lib32] (Artix ships it commented out)
if ! grep -q '^\[lib32\]' /etc/pacman.conf; then
    if grep -q '^#\[lib32\]' /etc/pacman.conf; then
        # Uncomment the header and the Include line that follows it
        sudo sed -i '/^#\[lib32\]/,/^#Include/ s/^#//' /etc/pacman.conf
    else
        # No commented block found, so add one
        sudo tee -a /etc/pacman.conf << 'EOF' > /dev/null

[lib32]
Include = /etc/pacman.d/mirrorlist
EOF
    fi
fi

# Arch repos on Artix (extra + multilib)
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm artix-archlinux-support lib32-artix-archlinux-support

# Append AFTER the Artix repos (the script runs after the lib32 block, so this holds)
for repo in extra multilib; do
    if ! grep -q "^\[$repo\]" /etc/pacman.conf; then
        sudo tee -a /etc/pacman.conf << EOF > /dev/null

[$repo]
Include = /etc/pacman.d/mirrorlist-arch
EOF
    fi
done

sudo pacman-key --populate archlinux

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
sudo pacman --noconfirm -S xorg lightdm lightdm-gtk-greeter lightdm-openrc\
                           alacritty git fastfetch firefox pipewire lib32-pipewire pipewire-pulse \
                           pipewire-alsa pipewire-jack wireplumber pavucontrol \
                           xdg-user-dirs zsh gvfs-mtp gvfs-gphoto2 calibre iw \
                           qbittorrent bc mpd ncmpcpp ntp adobe-source-han-sans-jp-fonts \
                           adobe-source-han-serif-jp-fonts r rstudio-desktop ibus-mozc \
                           peazip rsync wget network-manager-applet fuse2 ntfs-3g mpv gparted \
                           yt-dlp syncthing anki \
                           vulkan-intel lib32-vulkan-intel ffmpeg appimagelauncher\
                           gallery-dl mesa fooyin ifuse usbmuxd \
                           jdk8-openjdk exfatprogs mpc qtile qtile-extras lxappearance htop \
                           python-psutil ranger feh python-iwlib rofi xdg-desktop-portal \
                           xdg-desktop-portal-gtk picom networkmanager-dmenu gsimplecal \
                           mousepad xfce4-screenshooter xfce4-taskmanager yay-bin python-aiohttp

#sudo pacman -S timeshift cron libreoffice-fresh os-prober
#
#
# yay -S gtk3-patched-filechooser-icon-view glib2-patched-thumbnailer papirus-icon-theme-git \
#	       ibus-autostart jdownloader2 qdirstat-bin ttf-sil-fonts
yay -S nitrogen python-aiohttp ttf-sil-fonts ibus-autostart

xdg-user-dirs-update
sudo rc-update add lightdm default

# Mover archivos de configuración
sudo rsync -a /home/jairo/dotfiles/.config /home/jairo
sudo rsync -a /home/jairo/dotfiles/.local /home/jairo
sudo rsync -a /home/jairo/dotfiles/.icons /home/jairo
sudo rsync -a /home/jairo/dotfiles/xfce4-genmon-scripts /home/jairo
sudo rsync -a /home/jairo/dotfiles/usr/share/fonts/ /usr/share/fonts
sudo rsync -a /home/jairo/dotfiles/etc/environment /etc
sudo rsync -a /home/jairo/dotfiles/.jd/cfg /home/jairo/.jd/cfg

