#!/bin/bash
# My Hyprland Testing Script

# Define an array of ANSI color codes for random colors
colors=("$(tput setaf 1)" "$(tput setaf 2)" "$(tput setaf 3)" "$(tput setaf 4)" "$(tput setaf 5)" "$(tput setaf 6)" "$(tput setaf 7)" "$(tput setaf 8)" "$(tput setaf 9)" "$(tput setaf 10)")

# Function to get a random color
get_random_color() {
    local num_colors=${#colors[@]}
    local random_index=$((RANDOM % num_colors))
    echo "${colors[$random_index]}"
}

# Set the colors for each section
OK="$(get_random_color)[OK]$(tput sgr0)"
ERROR="$(get_random_color)[ERROR]$(tput sgr0)"
NOTE="$(get_random_color)[NOTE]$(tput sgr0)"
WARN="$(get_random_color)[WARN]$(tput sgr0)"
CAT="$(get_random_color)[ACTION]$(tput sgr0)"

# Function to install packages and show status
install_and_display_status() {
    local package_name="$1"
    local category="$2"

    local random_color="$(get_random_color)"
    printf "%s Installing %s: %s\n" "$random_color" "$category" "$package_name"
    install_package "$package_name" 2>&1 | tee -a $LOG

    if [ $? -ne 0 ]; then
        printf "\e[1A\e[K%s - %s install had failed, please check the install.log\n" "${ERROR}" "$package_name"
        exit 1
    fi
}

# Function for installing packages
install_package() {
    # Check if the package is already installed
    if $ISAUR -Q $1 &>> /dev/null ; then
        echo -e "${OK} $1 is already installed. Skipping..."
    else
        # Package not installed
        echo -e "${NOTE} Installing $1 ..."
        $ISAUR -S --noconfirm $1 2>&1 | tee -a $LOG
        # Make sure the package is installed
        if $ISAUR -Q $1 &>> /dev/null ; then
            echo -e "\e[1A\e[K${OK} $1 was installed."
        else
            # Something is missing, exit to review log
            echo -e "\e[1A\e[K${ERROR} $1 failed to install, please check the install.log. You may need to install it manually."
            exit 1
        fi
    fi
}

# Clear the screen
clear

# Print password warning message
printf "\n${YELLOW} Some commands require you to enter your password to execute. If you are worried about entering your password, you can cancel the script now with CTRL+C and review the script contents.${RESET}\n"
sleep 2
printf "\n\n"

# Ask the user if they want to proceed
read -n1 -rep "${CAT} Do you want to install (y/n) " PROCEED
echo
if [[ $PROCEED =~ ^[Yy]$ ]]; then
    printf "\n%s Let's Start.\n" "${OK}"
else
    printf "\n%s No changes made to your system. Exiting Now.\n" "${NOTE}"
    exit
fi

# Clear the screen
clear

# Check for AUR helper and install if not found
ISAUR=$(command -v yay || command -v paru)

if [ -n "$ISAUR" ]; then
    printf "\n%s - AUR helper was located, moving on.\n" "${OK}"
else 
    printf "\n%s - AUR helper was NOT located\n" "$WARN"

    while true; do
        read -rp "${CAT} Which AUR helper do you want to use, yay or paru? Enter 'y' or 'p': " choice 
        case "$choice" in
            y|Y)
                helper="yay"
                break
                ;;
            p|P)
                helper="paru"
                break
                ;;
            *)
                printf "%s - Invalid choice. Please enter 'y' or 'p'\n" "${ERROR}"
                continue
                ;;
        esac
    done

    printf "\n%s - Installing $helper from AUR\n" "${NOTE}"
    git clone https://aur.archlinux.org/"$helper"-bin.git || { printf "%s - Failed to clone $helper from AUR\n" "${ERROR}"; exit 1; }
    cd "$helper"-bin || { printf "%s - Failed to enter $helper-bin directory\n" "${ERROR}"; exit 1; }
    makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install $helper from AUR\n" "${ERROR}"; exit 1; }
    cd ..
fi

# Clear the screen
clear

# Update the system before proceeding
printf "\n%s - Performing a full system update to avoid issues....\n" "${NOTE}"

# Recheck for the AUR helper as it may have been installed in the previous step
ISAUR=$(command -v yay || command -v paru)

"$ISAUR" -Syu --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to update system\n" "${ERROR}"; exit 1; }

# Clear the screen
clear

# Set the script to exit on error
set -e

# Exit immediately if a command exits with a non-zero status.

# Loop through PKG1
for PKG1 in dolphin dolphin-plugins kitty swaybg swaylock-effects aha wofi wlogout qt5-base mako grim slurp wl-clipboard polkit-kde-agent nwg-look-bin swww pipewire micro pipewire-alsa pavucontrol playerctl file-roller feh geany zip unzip unrar xarchiver p7zip geany-plugins ranger yt-dlp timidity mpd ncmpcpp ani-cli lobster-git maim; do
    install_and_display_status "$PKG1" "PKG1"
done

# Loop through PKG2
for PKG2 in wayland wayland-protocols qt-wayland qt6-wayland lds lxappearance-gtk3 aalib chezmoi dex dmidecode jp2a spyder jupyterlab tomlplusplus starship jq gvfs gvfs-mtp ffmpegthumbs mpv python-requests pamixer mpv-mpris brightnessctl xdg-user-dirs imv xdg-user-dirs-gtk mpv network-manager-applet cava rofi-emoji alacritty starship rofi gnome-keyring acpi zathura-pdf-mupdf zathura swaync ffmpegthumbnailer starship zsh ascii; do
    install_and_display_status "$PKG2" "PKG2"
done

# Loop through PKG3
for PKG3 in lib32-libdecor lib32-libva lib32-wayland wlroots wl-clipboard cliphist cd ~/.config/hypr/themes clipman udisks2 udisks2-qt5 udiskie gdb ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite xorg-xinput libxrender pixman wlrobs-hg wrappedhl cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio; do
    install_and_display_status "$PKG3" "PKG3"
done

# Set the script to exit on error
set -e

# Clear the screen
clear

# Check if ly is already installed
if command -v ly >/dev/null; then
    printf "${NOTE} ly is already installed.\n"
elif command -v sddm >/dev/null; then
    # If SDDM is installed, disable other login managers
    for login_manager in lightdm gdm lxdm lxdm-gtk3; do
        if pacman -Qs "$login_manager" > /dev/null; then
            echo "Disabling $login_manager..."
            sudo systemctl disable "$login_manager.service" 2>&1 | tee -a $LOG
        fi
    done
    # Activate SDDM
    printf "Activating SDDM service...\n"
    sudo systemctl enable sddm
else
    printf "No login manager is installed.\n"
fi

# Prompt the user about which XDG-Portals to install
printf "${CAT} Choose which XDG-Portals to install (separate choices with commas):\n"
printf "  (g)nome - GNOME\n"
printf "  (h)yprland - Hyprland\n"
printf "  (k)de - KDE\n"
printf "  (w)lr - WLR (Wayland Reference Implementation)\n"
printf "  (l)xqt - LXQt\n"
printf "  (gtk) - GTK (xdg-desktop-portal-gtk)\n"
printf "  (n)one - Do not install any XDG-Portals\n"

read -p "Enter your choice(s): " XDG_CHOICES

IFS=',' read -ra CHOICES <<< "$XDG_CHOICES"

for CHOICE in "${CHOICES[@]}"; do
    case "$CHOICE" in
        [Gg]*)
            XDG_PACKAGE="xdg-desktop-portal-gnome"
            XDG_NAME="GNOME"
            ;;
        [Hh]*)
            XDG_PACKAGE="xdg-desktop-portal-hyprland"
            XDG_NAME="Hyprland"
            ;;
        [Kk]*)
            XDG_PACKAGE="xdg-desktop-portal-kde"
            XDG_NAME="KDE"
            ;;
        [Ww]*)
            XDG_PACKAGE="xdg-desktop-portal-wlr"
            XDG_NAME="WLR (Wayland Reference Implementation)"
            ;;
        [Ll]*)
            XDG_PACKAGE="xdg-desktop-portal-lxqt"
            XDG_NAME="LXQt"
            ;;
        [Gg]*)
            XDG_PACKAGE="xdg-desktop-portal-gtk"
            XDG_NAME="GTK"
            ;;
        *)
            XDG_PACKAGE=""
            ;;
    esac

    if [ -n "$XDG_PACKAGE" ]; then
        printf "${NOTE} Installing $XDG_NAME XDG-Portal...\n"

        # Install the chosen XDG-Portal
        install_package "$XDG_PACKAGE" 2>&1 | tee -a $LOG

        if [ $? -ne 0 ]; then
            printf "\e[1A\e[K%s - $XDG_NAME XDG-Portal install had failed, please check the install.log\n" "${ERROR}"
            exit 1
        fi
    else
        printf "${NOTE} No XDG-Portal selected for installation.\n"
    fi
done

# Disable WiFi powersave
LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
if [ -f "$LOC" ]; then
    printf "${OK} WiFi powersave is already disabled.\n"
else
    printf "${NOTE} Disabling WiFi powersave...\n"
    printf "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC
    printf "\n"
    printf "${NOTE} Restarting NetworkManager service...\n"
    sudo systemctl restart NetworkManager 2>&1 | tee -a $LOG
    sleep 2
fi

# Clear the screen
clear

# Copy Config Files
set -e

read -n1 -rep "${CAT} Would you like to copy config and wallpaper files? (y,n)" CFG
if [[ $CFG =~ ^[Yy]$ ]]; then

    # Check for existing config folders and backup
    for DIR in btop cava hypr foot mako swaylock waybar wlogout wofi; do
        DIRPATH=~/.config/$DIR
        if [ -d "$DIRPATH" ]; then
            echo -e "${NOTE} - Config for $DIR found, attempting to back up."
            mv $DIRPATH $DIRPATH-back-up 2>&1 | tee -a $LOG
            echo -e "${NOTE} - Backed up $DIR to $DIRPATH-back-up."
        fi
    done

    printf "Copying config files...\n"
    mkdir -p ~/.config
    cp -r config/* ~/.config/ || { echo "Error: Failed to copy configs."; exit 1; } 2>&1 | tee -a $LOG
    cp -r home/* ~/ || { echo "Error: Failed to copy configs."; exit 1; } 2>&1 | tee -a $LOG

    # Set some files as executable
    chmod +x ~/.config/hypr/scripts/* 2>&1 | tee -a "$LOG"
else
    print_error "No Config files and wallpaper files copied"
fi

# Clear the screen
clear

# Script is done
printf "\n${OK} Installation Completed.\n\n"

# Start Hyprland
read -n1 -rep "${CAT} Would you like to start Hyprland now? (y,n)" HYP

if [[ $HYP =~ ^[Yy]$ ]]; then
    if command -v sddm >/dev/null; then
        sudo systemctl start sddm 2>&1 | tee -a $LOG
    fi

    if command -v Hyprland >/dev/null; then
        exec Hyprland
    else
        print_error "Hyprland not found. Please make sure Hyprland is installed by checking install.log.\n"
        exit 1
    fi
else
    exit
fi
