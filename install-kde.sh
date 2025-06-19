#!/bin/bash

set -e

# Couleurs
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${YELLOW}Détection de la distribution...${RESET}"

# Détection de la distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo -e "${RED}Impossible de détecter la distribution.${RESET}"
    exit 1
fi

echo -e "${GREEN}Distribution détectée: $DISTRO${RESET}"
read -p "Souhaitez-vous installer KDE Plasma avec toutes ses dépendances ? (o/n): " confirm
if [[ "$confirm" != "o" && "$confirm" != "O" ]]; then
    echo "Installation annulée."
    exit 0
fi

case "$DISTRO" in
    fedora)
        echo -e "${GREEN}Installation de KDE sur Fedora...${RESET}"
        sudo dnf groupinstall -y "KDE Plasma Workspaces" "KDE Applications"
        sudo dnf install -y \
            sddm network-manager-applet pulseaudio alsa-utils \
            xdg-user-dirs noto-sans-fonts gnome-keyring \
            kde-settings-plasma

        sudo systemctl enable sddm
        sudo systemctl set-default graphical.target
        ;;

    ubuntu|debian)
        echo -e "${GREEN}Installation de KDE sur Ubuntu/Debian...${RESET}"
        sudo apt update
        sudo apt install -y \
            kde-full sddm \
            network-manager plasma-nm \
            pulseaudio alsa-utils \
            xdg-user-dirs fonts-noto \
            gnome-keyring

        sudo systemctl enable sddm
        sudo systemctl set-default graphical.target
        ;;

    arch)
        echo -e "${GREEN}Installation de KDE sur Arch Linux...${RESET}"
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm \
            plasma kde-applications sddm \
            networkmanager plasma-nm \
            pulseaudio alsa-utils \
            noto-fonts xdg-user-dirs \
            gnome-keyring

        sudo systemctl enable sddm
        sudo systemctl enable NetworkManager
        sudo systemctl set-default graphical.target
        ;;

    *)
        echo -e "${RED}Distribution non prise en charge par ce script.${RESET}"
        exit 1
        ;;
esac

echo -e "${GREEN}Installation complète. Redémarrez votre système pour démarrer dans KDE Plasma.${RESET}"
