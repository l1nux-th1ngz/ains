#!/bin/bash

# Create the directory if it doesn't exist
mkdir -p ~/.config/hypr/themes

# Change to the themes directory
cd ~/.config/hypr/themes

# Clone the neon-hyprland-theme
git clone https://github.com/taylor85345/neon-hyprland-theme neon
echo "Add source=~/.config/hypr/themes/neon/theme.conf"

# Clone the garden-hyprland-theme
git clone https://github.com/taylor85345/garden-hyprland-theme garden
echo "Add source=~/.config/hypr/themes/garden/theme.conf"

# Clone the cyber-hyprland-theme
git clone https://github.com/taylor85345/cyber-hyprland-theme cyber
echo "Add source=~/.config/hypr/themes/cyber/theme.conf"

# Clone the dracula-hyprland-theme
git clone https://github.com/dracula/hyprland.git
echo "Add source=~/.config/hypr/themes/dracula/theme.conf"

# Clone the dotfiles repository
git clone https://github.com/maximbaz/dotfiles.git ~/.dotfiles
echo "Add source=~/.config/hypr/themes/kakoune/theme.conf"

# Clone the dots-hyprland repository
git clone https://github.com/end-4/dots-hyprland.git

# Clone the dotfiles-hyprland repository
git clone https://github.com/AmadeusWM/dotfiles-hyprland.git
echo "Add source=~/.config/hypr/themes/ama/theme.conf"

# Clone the dotfiles repository
git clone https://github.com/lokesh-krishna/dotfiles.git

# Clone the hyprtheme repository
git clone https://github.com/hyprland-community/hyprtheme
cd hyprtheme
make all
