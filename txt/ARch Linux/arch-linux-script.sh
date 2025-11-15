#!/bin/bash

# =========================================================
# Arch Linux Post-Installation Script
# Automated setup for AMD Ryzen 5700X and RX 6600 XT
# Author: CalebOWolf
# Date: November 15, 2025
# =========================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root. Run as regular user with sudo access."
        exit 1
    fi
}

# Check internet connectivity
check_internet() {
    log_info "Checking internet connectivity..."
    if ! ping -c 1 archlinux.org &> /dev/null; then
        log_error "No internet connection. Please check your network."
        exit 1
    fi
    log_success "Internet connection verified"
}

# Update system and refresh keyrings
update_system() {
    log_info "Updating system and refreshing keyrings..."
    
    # Refresh Arch Linux keyring
    sudo pacman -Sy archlinux-keyring --noconfirm --needed
    
    # Update pacman database and upgrade system
    sudo pacman -Syu --noconfirm
    
    log_success "System updated successfully"
}

# Install AMD hardware support (Ryzen 5700X & RX 6600 XT)
install_amd_support() {
    log_info "Installing AMD hardware support for Ryzen 5700X and RX 6600 XT..."
    
    local amd_packages=(
        # AMD CPU microcode
        "amd-ucode"
        
        # Mesa drivers for AMD GPU
        "mesa"
        "lib32-mesa"
        
        # Vulkan drivers for AMD
        "vulkan-radeon" 
        "lib32-vulkan-radeon"
        
        # Additional AMD utilities
        "radeontop"
        "corectrl"
        
        # CPU frequency scaling
        "cpupower"
        "tuned"
    )
    
    sudo pacman -S --noconfirm --needed "${amd_packages[@]}"
    
    # Enable CPU governor for better performance
    sudo systemctl enable cpupower.service
    
    log_success "AMD hardware support installed"
}

# Install Aura AUR helper
install_aura() {
    log_info "Installing Aura AUR helper..."
    
    # Check if Aura is already installed
    if command -v aura &> /dev/null; then
        log_warning "Aura is already installed"
        return 0
    fi
    
    # Install base-devel if not present
    sudo pacman -S --noconfirm --needed base-devel git
    
    # Clone and build Aura
    cd /tmp
    git clone https://aur.archlinux.org/aura-bin.git
    cd aura-bin
    makepkg -si --noconfirm
    cd ~
    
    log_success "Aura AUR helper installed"
}

# Install packages from official repositories
install_arch_packages() {
    log_info "Installing packages from official Arch repositories..."
    
    local arch_packages=(
        # System utilities
        "openssh" "curl" "wget" "git" "vim" "nano" "htop" "lm_sensors"
        "base-devel" "gcc" "make" "dkms" "sed" "xargs"
        
        # Terminal utilities
        "bat" "fzf" "tmux" "zsh" "nnn" "nmtui" "ncdu" "mc"
        
        # Fonts and display
        "xorg-x11-font-utils" "fontconfig" "ttf-arimo-nerd" "noto-fonts" "otf-font-awesome"
        
        # Audio/Video
        "pipewire" "wireplumber" "pavucontrol" "pavucontrol-qt" 
        "gst-plugins-bad" "gst-plugins-base" "gst-plugins-good" "gst-plugins-ugly"
        "lib32-gst-plugins-base" "lib32-gst-plugins-good" "lib32-libpulse"
        "lib32-alsa-plugins" "lib32-alsa-lib" "ffmpeg"
        
        # Multimedia applications
        "vlc" "audacity" "gimp" "krita" "blender" "obs-studio" "kdenlive"
        "simplescreenrecorder" "handbrake"
        
        # Productivity
        "libreoffice-fresh" "firefox" "thunderbird" "nextcloud" "gvfs-google"
        
        # Gaming
        "steam" "lutris" "gamescope" "gamemode"
        
        # System tools
        "bleachbit" "gparted" "gwenview" "thunar" "thunar-archive-plugin"
        "thunar-media-tags-plugin" "thunar-volman"
        
        # Desktop environment components
        "qt5-wayland" "qt6-wayland" "xdg-user-dirs" "xorg-xwayland" "wayland"
        "gnome-settings-daemon" "gnome-tweaks"
        
        # Bluetooth
        "bluez" "bluez-utils" "blueberry"
        
        # Communication
        "discord" "telegram-desktop"
        
        # Utilities
        "hyfetch" "playerctl" "notify-send" "xdotool" "youtube-dl" "kitty"
        
        # Additional libraries
        "libidn11" "lib32-libidn11"
        
        # Music player
        "cmus"
    )
    
    # Install packages in chunks to avoid issues
    local chunk_size=20
    for ((i=0; i<${#arch_packages[@]}; i+=chunk_size)); do
        local chunk=("${arch_packages[@]:i:chunk_size}")
        sudo pacman -S --noconfirm --needed "${chunk[@]}"
        log_info "Installed chunk $((i/chunk_size + 1))"
    done
    
    log_success "Official Arch packages installed"
}

# Install AUR packages using Aura
install_aur_packages() {
    log_info "Installing AUR packages using Aura..."
    
    local aur_packages=(
        "google-chrome"
        "visual-studio-code-bin"
        "1password"
        "openrgb"
    )
    
    for package in "${aur_packages[@]}"; do
        log_info "Installing AUR package: $package"
        aura -A --noconfirm "$package"
    done
    
    log_success "AUR packages installed"
}

# Setup Flatpak and install applications
setup_flatpak() {
    log_info "Setting up Flatpak and installing applications..."
    
    # Install Flatpak
    sudo pacman -S --noconfirm --needed flatpak
    
    # Add Flathub repository
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    local flatpak_apps=(
        "com.discordapp.Discord"
        "org.telegram.desktop" 
        "org.firestormviewer.FirestormViewer"
        "org.prismlauncher.PrismLauncher"
        "io.github.shiftey.Desktop"
        "io.mgba.mGBA"
        "sh.ppy.osu"
        "org.ppsspp.PPSSPP"
        "com.vysp3r.ProtonPlus"
        "net.davidotek.pupgui2"
        "net.rpcs3.RPCS3"
        "app.twintaillauncher.ttl"
        "com.github.joseexposito.touche"
        "org.nickvision.tubeconverter"
        "org.qbittorrent.qBittorrent"
        "org.remmina.Remmina"
        "com.transmissionbt.Transmission"
        "com.github.unrud.VideoDownloader"
        "io.github.wivrn.wivrn"
        "org.audacityteam.Audacity"
        "com.rafaelmardojai.Blanket"
        "io.github.celluloid_player.Celluloid"
        "com.obsproject.Studio"
        "fr.handbrake.ghb"
        "org.kde.kdenlive"
        "de.haeckerfelix.Shortwave"
        "io.github.arunsivaramanneo.GPUViewer"
        "io.gitlab.adhami3310.Impression"
        "io.github.ilya_zlobintsev.LACT"
        "com.usebottles.bottles"
        "com.github.tchx84.Flatseal"
        "it.mijorus.gearlever"
        "org.keepassxc.KeePassXC"
        "org.localsend.localsend_app"
        "org.x.Warpinator"
        "io.github.fastrizwaan.WineZGUI"
    )
    
    # Install Flatpak applications
    for app in "${flatpak_apps[@]}"; do
        log_info "Installing Flatpak: $app"
        flatpak install -y flathub "$app"
    done
    
    log_success "Flatpak applications installed"
}

# Configure system services
configure_services() {
    log_info "Configuring system services..."
    
    # Enable Bluetooth
    sudo systemctl enable bluetooth.service
    sudo systemctl start bluetooth.service
    
    # Enable SSH (optional)
    sudo systemctl enable sshd.service
    
    # Enable tuned for better performance
    sudo systemctl enable tuned.service
    sudo systemctl start tuned.service
    sudo tuned-adm profile desktop
    
    log_success "System services configured"
}

# Main execution function
main() {
    log_info "Starting Arch Linux post-installation script..."
    log_info "This script is optimized for AMD Ryzen 5700X and RX 6600 XT"
    
    check_root
    check_internet
    update_system
    install_amd_support
    install_aura
    install_arch_packages
    install_aur_packages
    setup_flatpak
    configure_services
    
    log_success "Installation completed successfully!"
    log_info "Please reboot your system to ensure all changes take effect."
    log_info "After reboot, you may want to:"
    log_info "  - Configure your desktop environment"
    log_info "  - Set up your user preferences"
    log_info "  - Test gaming performance with your AMD setup"
}

# Run main function
main "$@"
