#!/bin/bash

#nvim essentials
sudo pacman -S neovim git curl unzip ripgrep fd nodejs npm texlive texlive-lang \
               zathura zathura-pdf-poppler xclip tree-sitter-cli ttf-jetbrains-mono-nerd

#nvchad
git clone https://github.com/NvChad/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
#:TSInstall html css javascript typescript tsx json markdown yaml toml bash python lua vim vimdoc query regex

#oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo rsync -a /home/jairo/dotfiles/.oh-my-zsh  /home/jairo
sudo rsync -a /home/jairo/dotfiles/.zshrc /home/jairo
