#!/bin/bash

# Instalar programas esenciales
sudo pacman -S networkmanager grub efibootmgr xorg lightdm lightdm-gtk-greeter xfce4 xfce4-goodies alacritty git neofetch firefox rofi pulseaudio pavucontrol htop xdg-user-dirs zsh gvfs-mtp gvfs-gphoto2 calibre qbittorrent bc mpd ncmpcpp ntp cron adobe-source-han-sans-jp-fonts adobe-source-han-serif-jp-fonts r rstudio-desktop timeshift ibus-mozc p7zip-gui rsync wget

# qtile
# sudo pacman -S qtile nitrogen lxappearance htop python-psutil ranger feh flameshot pcmanfn-gtk3 python-iwlib

xdg-user-dirs-update
systemctl enable lightdm

# Oh my zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Horario
timedatectl set-timezone America/Mexico_City
timedatectl set-ntp true
systemctl restart systemd-timesyncd

# AUR
mkdir Downloads/git
cd Downloads/git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -sri
cd
#yay -S gtk3-patched-filechooser-icon-view glib2-patched-thumbnailer papirus-icon-theme-git

# Mover archivos de configuración
sudo rsync -a /home/jairo/dotfiles/.config /home/jairo
sudo rsync -a /home/jairo/dotfiles/.icons /home/jairo
sudo rsync -a /home/jairo/dotfiles/.oh-my-zsh  /home/jairo
sudo rsync -a /home/jairo/dotfiles/.zshrc /home/jairo
