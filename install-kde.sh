#!/bin/bash

set -e

# Colors
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${YELLOW}Detecting distribution...${RESET}"

# Distribution detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo -e "${RED}Unable to detect distribution.${RESET}"
    exit 1
fi

echo -e "${GREEN}Distribution detected: $DISTRO${RESET}"
read -p "Do you want to install KDE Plasma with all dependencies? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Display Manager choice
while true; do
    echo -e "\n${YELLOW}Choose your display manager:${RESET}"
    echo "1) SDDM (recommended)"
    echo "2) LightDM"
    echo "3) No display manager"
    read -p "Your choice (1-3): " dm_choice
    
    case $dm_choice in
        1)
            DM_PACKAGE="sddm"
            break
            ;;
        2)
            DM_PACKAGE="lightdm lightdm-gtk-greeter"
            break
            ;;
        3)
            DM_PACKAGE=""
            break
            ;;
        *)
            echo -e "${RED}Invalid choice. Please choose 1, 2 or 3.${RESET}"
            ;;
    esac
done

# Optional packages configuration
echo -e "\n${YELLOW}Optional packages configuration:${RESET}"

# Additional KDE applications
read -p "Do you want to install additional KDE applications? (y/n): " extra_apps
if [[ "$extra_apps" == "y" || "$extra_apps" == "Y" ]]; then
    read -p "Do you want to install Krita (graphics editor)? (y/n): " krita
    read -p "Do you want to install KDevelop (IDE)? (y/n): " kdevelop
    read -p "Do you want to install Kdenlive (video editor)? (y/n): " kdenlive
fi

# Themes and customizations
read -p "Do you want to install themes and customizations? (y/n): " themes
if [[ "$themes" == "y" || "$themes" == "Y" ]]; then
    read -p "Do you want to install additional KDE themes? (y/n): " kde_themes
    read -p "Do you want to install additional icons? (y/n): " icons
    read -p "Do you want to install desktop effects? (y/n): " desktop_effects
    read -p "Do you want to install additional widgets? (y/n): " widgets
fi

# Development tools
read -p "Do you want to install development tools? (y/n): " dev_tools
if [[ "$dev_tools" == "y" || "$dev_tools" == "Y" ]]; then
    read -p "Do you want to install Qt Creator? (y/n): " qt_creator
    read -p "Do you want to install Git? (y/n): " git
fi

# Building optional packages list
EXTRA_PACKAGES=""

# KDE applications
if [[ "$extra_apps" == "y" || "$extra_apps" == "Y" ]]; then
    if [[ "$krita" == "y" || "$krita" == "Y" ]]; then
        EXTRA_PACKAGES+=" krita"
    fi
    if [[ "$kdevelop" == "y" || "$kdevelop" == "Y" ]]; then
        EXTRA_PACKAGES+=" kdevelop"
    fi
    if [[ "$kdenlive" == "y" || "$kdenlive" == "Y" ]]; then
        EXTRA_PACKAGES+=" kdenlive"
    fi
fi

# Themes and customizations
if [[ "$themes" == "y" || "$themes" == "Y" ]]; then
    if [[ "$kde_themes" == "y" || "$kde_themes" == "Y" ]]; then
        EXTRA_PACKAGES+=" breeze-gtk breeze-icons"
    fi
    if [[ "$icons" == "y" || "$icons" == "Y" ]]; then
        EXTRA_PACKAGES+=" breeze-cursor-theme"
    fi
    if [[ "$desktop_effects" == "y" || "$desktop_effects" == "Y" ]]; then
        EXTRA_PACKAGES+=" kwin-effects kwin-addons kwin-transitions"
    fi
    if [[ "$widgets" == "y" || "$widgets" == "Y" ]]; then
        EXTRA_PACKAGES+=" plasma-widgets-addons plasma-wallpapers-addons"
    fi
fi

# Development tools
if [[ "$dev_tools" == "y" || "$dev_tools" == "Y" ]]; then
    if [[ "$qt_creator" == "y" || "$qt_creator" == "Y" ]]; then
        EXTRA_PACKAGES+=" qtcreator"
    fi
    if [[ "$git" == "y" || "$git" == "Y" ]]; then
        EXTRA_PACKAGES+=" git"
    fi
fi

# Main packages installation
base_packages="$DM_PACKAGE \
    kwin kwantum kwallet-pam kde-gtk-config \
    network-manager-applet pulseaudio alsa-utils \
    xdg-user-dirs noto-sans-fonts gnome-keyring \
    kde-settings-plasma \
    kde-plasma-desktop kde-plasma-workspace kde-plasma-addons \
    kde-systemsettings kde-config-systemd \
    kde-config-sddm kde-config-gtk-style \
    kde-config-notify kde-config-updates \
    kde-config-locale kde-config-telepathy-accounts \
    kde-config-screensaver kde-config-display \
    kde-config-clipboard kde-config-desktop-effects \
    kde-config-desktop-icons kde-config-desktop-fonts \
    kde-config-desktop-wallpaper kde-config-desktop-background \
    kde-config-desktop-behavior kde-config-desktop-notification \
    kde-config-desktop-color-scheme kde-config-desktop-animations \
    kde-config-desktop-layout kde-config-desktop-shortcuts"

# Installation selon la distribution
case "$DISTRO" in
    fedora)
        echo -e "${GREEN}Installation de KDE sur Fedora...${RESET}"
        sudo dnf groupinstall -y "KDE Plasma Workspaces" "KDE Applications"
        sudo dnf install -y $base_packages
        
        if [ -n "$EXTRA_PACKAGES" ]; then
            echo -e "${GREEN}Installation des packages facultatifs...${RESET}"
            sudo dnf install -y $EXTRA_PACKAGES
        fi

        if [ -n "$DM_PACKAGE" ]; then
            sudo systemctl enable $DM_PACKAGE
            sudo systemctl set-default graphical.target
        fi
        ;;

    ubuntu|debian)
        echo -e "${GREEN}Installation de KDE sur Ubuntu/Debian...${RESET}"
        sudo apt update
        sudo apt install -y kde-full
        sudo apt install -y $base_packages
        
        if [ -n "$EXTRA_PACKAGES" ]; then
            echo -e "${GREEN}Installation des packages facultatifs...${RESET}"
            sudo apt install -y $EXTRA_PACKAGES
        fi

        if [ -n "$DM_PACKAGE" ]; then
            sudo systemctl enable $DM_PACKAGE
            sudo systemctl set-default graphical.target
        fi
        ;;

    arch)
        echo -e "${GREEN}Installation de KDE sur Arch Linux...${RESET}"
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm plasma kde-applications
        sudo pacman -S --noconfirm $base_packages
        
        if [ -n "$EXTRA_PACKAGES" ]; then
            echo -e "${GREEN}Installation des packages faculitatifs...${RESET}"
            sudo pacman -S --noconfirm $EXTRA_PACKAGES
        fi

        if [ -n "$DM_PACKAGE" ]; then
            sudo systemctl enable $DM_PACKAGE
            sudo systemctl enable NetworkManager
            sudo systemctl set-default graphical.target
        fi
        ;;

    *)
        echo -e "${RED}Distribution non prise en charge par ce script.${RESET}"
        exit 1
        ;;
esac

echo -e "${GREEN}Installation complète. Redémarrez votre système pour démarrer dans KDE Plasma.${RESET}"
