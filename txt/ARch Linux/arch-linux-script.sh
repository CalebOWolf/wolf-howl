#!/bin/bash

# =========================================================
# Arch Linux Post-Installation Script
# Automated setup for AMD Ryzen 5700X and RX 6600 XT
# 
# Author: CalebOWolf
# Date: November 15, 2025
# Repository: https://github.com/CalebOWolf/wolf-howl
# License: MIT (see LICENSE file)
# Version: 1.0
# =========================================================

# =========================================================
# DISCLAIMER AND LIABILITY NOTICE
# =========================================================
# 
# THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# IMPORTANT WARNINGS:
# - This script makes significant changes to your system
# - It installs packages, modifies configurations, and changes system settings
# - The author is NOT RESPONSIBLE for any data loss, system damage, or issues
# - You use this script entirely AT YOUR OWN RISK
# - It is STRONGLY RECOMMENDED to test on a virtual machine first
# - Always backup your important data before running system modification scripts
# - This script is designed for fresh Arch Linux installations
# - Running on existing systems may cause conflicts or unexpected behavior
#
# BY RUNNING THIS SCRIPT, YOU ACKNOWLEDGE THAT:
# - You understand the risks involved in automated system modification
# - You have backed up any important data
# - You accept full responsibility for any consequences
# - You will not hold the author liable for any damages or issues
#
# SUPPORT NOTICE:
# - This is open source software provided for free
# - No warranty, support, or maintenance is guaranteed
# - Use GitHub issues for bug reports and feature requests
# - Community contributions and improvements are welcome
#
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

# Pre-flight system checks
preflight_checks() {
    log_info "Performing pre-flight checks..."
    
    # Check if we're on Arch Linux
    if ! grep -q "Arch Linux" /etc/os-release 2>/dev/null; then
        log_error "This script is designed for Arch Linux only!"
        exit 1
    fi
    
    # Check if pacman is available
    if ! command -v pacman &>/dev/null; then
        log_error "Pacman package manager not found!"
        exit 1
    fi
    
    # Check if user has sudo access
    if ! sudo -n true 2>/dev/null; then
        log_info "Testing sudo access (you may be prompted for password)..."
        if ! sudo true; then
            log_error "This script requires sudo access!"
            exit 1
        fi
    fi
    
    # Check available disk space (at least 5GB free)
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 5242880 ]; then  # 5GB in KB
        log_warning "Low disk space detected. At least 5GB free space is recommended."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    log_success "Pre-flight checks completed"
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

# Install package group with error handling
install_package_group() {
    local group_name="$1"
    shift
    local packages=("$@")
    
    log_info "Installing $group_name..."
    
    # Filter out packages that don't exist
    local valid_packages=()
    for package in "${packages[@]}"; do
        if pacman -Si "$package" &>/dev/null; then
            valid_packages+=("$package")
        else
            log_warning "Package '$package' not found in repositories, skipping..."
        fi
    done
    
    # Install valid packages
    if [ ${#valid_packages[@]} -gt 0 ]; then
        if sudo pacman -S --noconfirm --needed "${valid_packages[@]}"; then
            log_success "$group_name installed successfully"
        else
            log_warning "Some packages in $group_name failed to install, continuing..."
        fi
    else
        log_warning "No valid packages found in $group_name"
    fi
}

# Enable multilib repository
enable_multilib() {
    log_info "Enabling multilib repository for 32-bit support..."
    
    # Check if multilib is already enabled
    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        log_warning "Multilib repository is already enabled"
        return 0
    fi
    
    # Enable multilib repository
    sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ {
        s/^#\[multilib\]/[multilib]/
        s/^#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/
    }' /etc/pacman.conf
    
    log_success "Multilib repository enabled"
}

# Update system and refresh keyrings
update_system() {
    log_info "Updating system and refreshing keyrings..."
    
    # Enable multilib first
    enable_multilib
    
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
    
    # Install dependencies for building AUR packages
    sudo pacman -S --noconfirm --needed base-devel git rust
    
    # Create temporary directory and clone Aura
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    log_info "Cloning Aura from AUR..."
    git clone https://aur.archlinux.org/aura-bin.git
    cd aura-bin
    
    # Build and install Aura
    log_info "Building Aura (this may take a few minutes)..."
    makepkg -si --noconfirm --needed
    
    # Clean up
    cd "$HOME"
    rm -rf "$temp_dir"
    
    # Verify installation
    if command -v aura &> /dev/null; then
        log_success "Aura AUR helper installed successfully"
    else
        log_error "Aura installation failed"
        exit 1
    fi
}

# Install packages from official repositories
install_arch_packages() {
    log_info "Installing packages from official Arch repositories..."
    
    # Core system packages (install first)
    local core_packages=(
        "base-devel" "git" "curl" "wget" "openssh" "vim" "nano" "htop"
        "lm_sensors" "gcc" "make" "dkms" "multilib-devel"
        # Dependencies for GUI applications like 1Password
        "nss" "gtk3" "libxss" "xdg-utils" "libxrandr" "alsa-lib"
        "cairo" "pango" "at-spi2-atk" "libdrm" "libxcomposite" "libxdamage"
    )
    
    # Terminal and CLI utilities
    local cli_packages=(
        "bat" "fzf" "tmux" "zsh" "nnn" "networkmanager" "ncdu" "mc" "tree"
    )
    
    # Fonts and display
    local font_packages=(
        "fontconfig" "noto-fonts" "ttf-dejavu" "ttf-liberation" "ttf-opensans"
    )
    
    # Audio/Video system
    local audio_packages=(
        "pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "wireplumber"
        "pavucontrol" "gst-plugins-base" "gst-plugins-good" "gst-plugins-bad" "gst-plugins-ugly"
        "lib32-pipewire" "lib32-gst-plugins-base" "lib32-gst-plugins-good"
        "ffmpeg" "lib32-alsa-plugins" "lib32-alsa-lib"
        # Screensharing support
        "xdg-desktop-portal-pipewire" "pipewire-v4l2"
    )
    
    # Multimedia applications
    local media_packages=(
        "vlc" "audacity" "gimp" "krita" "blender" "obs-studio" "kdenlive"
        "simplescreenrecorder" "handbrake"
    )
    
    # Productivity applications
    local productivity_packages=(
        "libreoffice-fresh" "firefox" "thunderbird" "gvfs-google"
    )
    
    # Gaming packages
    local gaming_packages=(
        "steam" "lutris" "gamemode"
    )
    
    # System tools
    local system_packages=(
        "gparted" "gwenview" "thunar" "thunar-archive-plugin"
        "thunar-media-tags-plugin" "thunar-volman" "xarchiver"
        # Dependencies for Discord rich presence
        "socat" "util-linux" "dbus"
    )
    
    # Desktop environment components
    local desktop_packages=(
        "qt5-wayland" "qt6-wayland" "xdg-user-dirs" "xorg-xwayland" "wayland-protocols"
        "xdg-desktop-portal" "xdg-desktop-portal-gtk" "xdg-desktop-portal-wlr"
        "xdg-desktop-portal-kde" "grim" "slurp" "wl-clipboard"
    )
    
    # Bluetooth support
    local bluetooth_packages=(
        "bluez" "bluez-utils"
    )
    
    # Communication (Telegram will be installed via Flatpak for better integration)
    local communication_packages=(
        # telegram-desktop removed - using Flatpak version for better system integration
    )
    
    # Utilities
    local utility_packages=(
        "hyfetch" "playerctl" "libnotify" "xdotool" "yt-dlp" "kitty" "cmus"
    )
    
    # Combine all package arrays
    local all_packages=(
        "${core_packages[@]}"
        "${cli_packages[@]}"
        "${font_packages[@]}"
        "${audio_packages[@]}"
        "${media_packages[@]}"
        "${productivity_packages[@]}"
        "${gaming_packages[@]}"
        "${system_packages[@]}"
        "${desktop_packages[@]}"
        "${bluetooth_packages[@]}"
        "${communication_packages[@]}"
        "${utility_packages[@]}"
    )
    
    # Install packages with better error handling
    install_package_group "Core System Packages" "${core_packages[@]}"
    install_package_group "CLI Utilities" "${cli_packages[@]}"
    install_package_group "Fonts" "${font_packages[@]}"
    install_package_group "Audio System" "${audio_packages[@]}"
    install_package_group "Multimedia Applications" "${media_packages[@]}"
    install_package_group "Productivity Applications" "${productivity_packages[@]}"
    install_package_group "Gaming Packages" "${gaming_packages[@]}"
    install_package_group "System Tools" "${system_packages[@]}"
    install_package_group "Desktop Components" "${desktop_packages[@]}"
    install_package_group "Bluetooth Support" "${bluetooth_packages[@]}"
    install_package_group "Communication Apps" "${communication_packages[@]}"
    install_package_group "Utility Applications" "${utility_packages[@]}"
    
    log_success "Official Arch packages installed"
}

# Install 1Password properly
install_1password() {
    log_info "Installing 1Password..."
    
    # Check if 1Password is already installed
    if command -v 1password &> /dev/null; then
        log_warning "1Password is already installed"
        return 0
    fi
    
    # Import 1Password signing key for package verification
    log_info "Importing 1Password signing key..."
    if curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import; then
        log_success "1Password signing key imported successfully"
    else
        log_warning "Failed to import 1Password signing key; continuing, but package verification may fail."
    fi

    # Try the official AUR package first (maintained by 1Password team)
    log_info "Installing 1Password from AUR (official package)..."
    if aura -A --noconfirm 1password; then
        log_success "1Password installed successfully from AUR"
        
        # Also install 1Password CLI
        log_info "Installing 1Password CLI..."
        if aura -A --noconfirm 1password-cli; then
            log_success "1Password CLI installed successfully"
        else
            log_warning "1Password CLI installation failed, but main app is installed"
        fi
        
        # Configure 1Password for better integration
        log_info "Configuring 1Password integration..."
        
        # Enable browser integration
        mkdir -p "$HOME/.config/1Password/settings"
        cat > "$HOME/.config/1Password/settings/settings.json" << 'EOF'
{
  "version": 1,
  "integrations": {
    "browserIntegration": {
      "enabled": true,
      "supportedBrowsers": {
        "firefox": true,
        "chrome": true,
        "chromium": true,
        "edge": true
      }
    }
  },
  "security": {
    "autolock": {
      "enabled": true,
      "minutes": 10
    }
  }
}
EOF
        
        # Create desktop integration
        mkdir -p "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/1password-quick-access.desktop" << 'EOF'
[Desktop Entry]
Name=1Password - Quick Access
Exec=1password --quick-access
Icon=1password
Type=Application
NoDisplay=true
StartupWMClass=1Password
EOF
        
        log_success "1Password configuration completed"
        log_info "1Password will auto-update through AUR package updates"
        
    else
        log_error "Failed to install 1Password from AUR"
        log_info "You can manually install it later with: aura -A 1password"
        return 1
    fi
}

# Install AUR packages using Aura
install_aur_packages() {
    log_info "Installing AUR packages using Aura..."
    
    local aur_packages=(
        "google-chrome"
        "visual-studio-code-bin"
        "openrgb"
    )
    
    for package in "${aur_packages[@]}"; do
        log_info "Installing AUR package: $package"
        if aura -A --noconfirm "$package"; then
            log_success "Successfully installed AUR package: $package"
        else
            log_warning "Failed to install AUR package: $package"
        fi
    done
    
    log_success "AUR packages installed"
}

# Clean up conflicting Discord installations
cleanup_discord_conflicts() {
    log_info "Cleaning up any conflicting Discord installations..."
    
    # Remove Discord from official repos if installed to avoid conflicts
    if pacman -Q discord &>/dev/null; then
        log_info "Removing Discord from official repositories to avoid update conflicts..."
        sudo pacman -R --noconfirm discord 2>/dev/null || log_warning "Could not remove system Discord package"
    fi
    
    # Remove any AUR Discord installations
    if pacman -Q discord-canary &>/dev/null; then
        log_info "Removing Discord Canary to avoid conflicts..."
        sudo pacman -R --noconfirm discord-canary 2>/dev/null || true
    fi
    
    # Clean up any old Discord update files
    rm -f "$HOME/.local/bin/discord-update-old" 2>/dev/null || true
    
    log_info "Discord conflict cleanup completed"
}

# Clean up conflicting Telegram installations
cleanup_telegram_conflicts() {
    log_info "Cleaning up any conflicting Telegram installations..."
    
    # Remove Telegram from official repos if installed to avoid conflicts
    if pacman -Q telegram-desktop &>/dev/null; then
        log_info "Removing Telegram from official repositories to avoid conflicts with Flatpak version..."
        sudo pacman -R --noconfirm telegram-desktop 2>/dev/null || log_warning "Could not remove system Telegram package"
    fi
    
    # Remove any old Telegram configuration conflicts
    rm -rf "$HOME/.local/share/TelegramDesktop" 2>/dev/null || true
    
    log_info "Telegram conflict cleanup completed"
}

# Setup Flatpak and install applications
setup_flatpak() {
    log_info "Setting up Flatpak and installing applications..."
    
    # Install Flatpak
    sudo pacman -S --noconfirm --needed flatpak
    
    # Add Flathub repository
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # Clean up Discord conflicts before installing Flatpak version
    cleanup_discord_conflicts
    
    # Clean up Telegram conflicts
    cleanup_telegram_conflicts
    
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
    
    # Install Flatpak applications with error handling
    # Use timeout to avoid getting stuck indefinitely on network/key issues
    for app in "${flatpak_apps[@]}"; do
        log_info "Installing Flatpak: $app"
        if timeout 300 flatpak install -y --noninteractive flathub "$app" 2>/dev/null; then
            log_success "Successfully installed: $app"
        else
            log_warning "Failed or timed out installing: $app (may not be available, already installed, or network is slow)"
        fi
    done
    
    log_success "Flatpak applications installed"
}

# Configure Telegram for system integration
configure_telegram() {
    log_info "Configuring Telegram for optimal system integration..."
    
    # Check if Telegram Flatpak is installed
    if ! flatpak list | grep -q "org.telegram.desktop"; then
        log_warning "Telegram Flatpak not found, skipping Telegram configuration"
        return 0
    fi
    
    # Create enhanced Telegram desktop entry
    local telegram_desktop_dir="$HOME/.local/share/applications"
    mkdir -p "$telegram_desktop_dir"
    
    cat > "$telegram_desktop_dir/telegram-enhanced.desktop" << 'EOF'
[Desktop Entry]
Name=Telegram (System Integrated)
Comment=Fast and secure desktop messaging app with full system integration
GenericName=Instant Messaging
Exec=flatpak run --socket=wayland --socket=x11 --socket=pulseaudio --share=network --share=ipc --device=dri --filesystem=xdg-download --filesystem=xdg-pictures --filesystem=xdg-documents --talk-name=org.freedesktop.Notifications --talk-name=org.kde.StatusNotifierItem --own-name=org.mpris.MediaPlayer2.telegram org.telegram.desktop -startintray
Icon=org.telegram.desktop
Type=Application
Categories=Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;x-scheme-handler/tonsite;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
StartupWMClass=TelegramDesktop
StartupNotify=true
X-GNOME-UsesNotifications=true
EOF

    # Configure Flatpak permissions for better system integration
    log_info "Setting up Telegram Flatpak permissions for system integration..."
    
    # Override permissions for optimal integration (log a warning instead of appearing to hang)
    flatpak override --user \
        --socket=wayland \
        --socket=x11 \
        --socket=pulseaudio \
        --share=network \
        --share=ipc \
        --device=dri \
        --filesystem=xdg-download \
        --filesystem=xdg-pictures \
        --filesystem=xdg-documents:ro \
        --filesystem=xdg-music:ro \
        --filesystem=xdg-videos:ro \
        --talk-name=org.freedesktop.Notifications \
        --talk-name=org.kde.StatusNotifierItem \
        --talk-name=org.freedesktop.portal.Desktop \
        --talk-name=org.freedesktop.portal.FileChooser \
    --talk-name=org.freedesktop.portal.Notification \
    --own-name=org.mpris.MediaPlayer2.telegram \
    org.telegram.desktop || log_warning "Telegram Flatpak override failed; you can adjust permissions later with Flatseal or flatpak override."
    
    # Set up system tray and notification integration
    log_info "Configuring system tray and notification integration..."
    
    # Create autostart entry for Telegram
    mkdir -p "$HOME/.config/autostart"
    cat > "$HOME/.config/autostart/telegram-autostart.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Telegram
Comment=Start Telegram minimized to system tray
Icon=org.telegram.desktop
Exec=flatpak run org.telegram.desktop -startintray -autostart
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
StartupNotify=false
Terminal=false
EOF

    # Create Telegram configuration directory and set up defaults
    mkdir -p "$HOME/.var/app/org.telegram.desktop/config/TelegramDesktop/tdata"
    
    # Configure Telegram settings for better system integration
    cat > "$HOME/.var/app/org.telegram.desktop/config/TelegramDesktop/telegram_settings.json" << 'EOF'
{
    "notifications": {
        "desktop_enabled": true,
        "sounds_enabled": true,
        "badge_enabled": true,
        "system_integration": true
    },
    "interface": {
        "tray_icon": true,
        "minimize_to_tray": true,
        "close_to_tray": true,
        "system_theme": true,
        "native_decorations": true
    },
    "media": {
        "auto_download_photos": true,
        "auto_play_gifs": true,
        "hardware_acceleration": true
    },
    "advanced": {
        "use_system_frame": true,
        "native_window_frame": true,
        "smooth_scrolling": true
    }
}
EOF

    # Create media integration script
    cat > "$HOME/.local/bin/telegram-media-handler" << 'EOF'
#!/bin/bash
# Telegram Media Handler for system integration

case "$1" in
    "image")
        # Handle image files
        flatpak run org.telegram.desktop "$2"
        ;;
    "video")
        # Handle video files
        flatpak run org.telegram.desktop "$2"
        ;;
    "audio")
        # Handle audio files
        flatpak run org.telegram.desktop "$2"
        ;;
    "document")
        # Handle document files
        flatpak run org.telegram.desktop "$2"
        ;;
    *)
        # Default handler
        flatpak run org.telegram.desktop "$@"
        ;;
esac
EOF
    
    chmod +x "$HOME/.local/bin/telegram-media-handler"
    
    # Set up MIME type associations for better file handling
    mkdir -p "$HOME/.local/share/mime/packages"
    cat > "$HOME/.local/share/mime/packages/telegram.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
    <mime-type type="application/x-telegram-document">
        <comment>Telegram Document</comment>
        <glob pattern="*.telegram"/>
    </mime-type>
</mime-info>
EOF
    
    # Update MIME database
    update-mime-database "$HOME/.local/share/mime" 2>/dev/null || true
    
    # Configure default applications for Telegram-related files
    mkdir -p "$HOME/.config"
    if [ ! -f "$HOME/.config/mimeapps.list" ]; then
        touch "$HOME/.config/mimeapps.list"
    fi
    
    # Add Telegram as handler for tg:// URLs and related file types
    cat >> "$HOME/.config/mimeapps.list" << 'EOF'

# Telegram Desktop Integration
[Added Associations]
x-scheme-handler/tg=org.telegram.desktop.desktop;
x-scheme-handler/tonsite=org.telegram.desktop.desktop;
application/x-telegram-document=org.telegram.desktop.desktop;
EOF

    log_success "Telegram system integration configured successfully"
    log_info "Telegram will now integrate properly with system notifications, tray, and file handling"
}

# Configure Discord for proper updates and screensharing
configure_discord() {
    log_info "Configuring Discord for proper updates and screensharing..."
    
    # Check if Discord Flatpak is installed
    if ! flatpak list | grep -q "com.discordapp.Discord"; then
        log_warning "Discord Flatpak not found, skipping Discord configuration"
        return 0
    fi
    
    # Create Discord desktop entry with proper flags for screensharing
    local discord_desktop_dir="$HOME/.local/share/applications"
    mkdir -p "$discord_desktop_dir"
    
    # Create custom Discord launcher with screensharing flags for Flatpak
    cat > "$discord_desktop_dir/discord-screenshare.desktop" << 'EOF'
[Desktop Entry]
Name=Discord (Screenshare & Auto-Update)
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers with proper screensharing and auto-updates
GenericName=Internet Messenger
Exec=flatpak run --socket=wayland --socket=pulseaudio --socket=session-bus --share=network --share=ipc --device=dri --filesystem=xdg-download --talk-name=org.freedesktop.Notifications --own-name=org.discord.Discord com.discordapp.Discord --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer --ozone-platform=wayland --disable-seccomp-filter-sandbox
Icon=com.discordapp.Discord
Type=Application
Categories=Network;InstantMessaging;
StartupNotify=true
EOF

    # Configure Flatpak Discord for better integration
    log_info "Configuring Flatpak Discord permissions for optimal performance..."
    
    # Grant necessary permissions for screensharing and updates; if they fail, log a warning and continue
    flatpak permission-set webkitgtk com.discordapp.Discord webkit:enable-webgl yes 2>/dev/null || log_warning "Failed to set Discord WebGL permission; continuing."
    flatpak permission-set portals.desktop com.discordapp.Discord screenshot yes 2>/dev/null || log_warning "Failed to set Discord screenshot permission; continuing."
    flatpak permission-set portals.desktop com.discordapp.Discord screencast yes 2>/dev/null || log_warning "Failed to set Discord screencast permission; continuing."
    
    # Override Flatpak permissions for better functionality including rich presence; log issues instead of appearing to hang
    flatpak override --user \
        --socket=wayland \
        --socket=pulseaudio \
        --socket=x11 \
        --socket=session-bus \
        --share=network \
        --share=ipc \
        --device=dri \
        --filesystem=xdg-download \
        --filesystem=xdg-pictures:ro \
        --talk-name=org.freedesktop.Notifications \
        --talk-name=org.kde.StatusNotifierItem \
        --talk-name=org.freedesktop.portal.Desktop \
    --own-name=org.discord.Discord \
    --own-name=com.discordapp.Discord \
    com.discordapp.Discord || log_warning "Discord Flatpak override failed; you can adjust permissions later with Flatseal or flatpak override."
    
    # Create update script for Discord
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/update-discord" << 'EOF'
#!/bin/bash
# Discord Auto-Update Script
echo "Checking for Discord updates..."
if flatpak update --noninteractive com.discordapp.Discord; then
    echo "Discord updated successfully!"
    # Kill existing Discord processes to restart with new version
    pkill -f "discord" 2>/dev/null || true
    pkill -f "Discord" 2>/dev/null || true
    sleep 2
    echo "Discord ready to restart with new version."
else
    echo "No Discord updates available or update failed."
fi
EOF
    
    chmod +x "$HOME/.local/bin/update-discord"
    
    # Also create environment file for system-wide Discord configuration
    sudo mkdir -p /etc/environment.d
    cat | sudo tee /etc/environment.d/10-discord-screenshare.conf > /dev/null << 'EOF'
# Discord screensharing configuration for Wayland
DISCORD_ENABLE_WAYLAND=1
XDG_CURRENT_DESKTOP=sway
# Ensure PipeWire is used for audio/video
PIPEWIRE_LATENCY=512/48000
# Enable rich presence and activity detection
DISCORD_RPC_API_ENDPOINT=127.0.0.1:6463
EOF

    # Configure Discord rich presence support
    log_info "Setting up Discord rich presence support..."
    
    # Create Discord RPC configuration
    mkdir -p "$HOME/.config/discord"
    cat > "$HOME/.config/discord/settings.json" << 'EOF'
{
  "SKIP_HOST_UPDATE": true,
  "IS_MAXIMIZED": false,
  "IS_MINIMIZED": false,
  "WINDOW_BOUNDS": {
    "x": 0,
    "y": 0,
    "width": 1280,
    "height": 720
  },
  "richPresence": {
    "enabled": true,
    "showCurrentGame": true,
    "showElapsedTime": true,
    "largeImageKey": "discord",
    "largeImageText": "Discord",
    "details": "Using Discord on Arch Linux",
    "state": "Online"
  },
  "activitySettings": {
    "detectGames": true,
    "showCurrentActivity": true,
    "shareActivityData": true
  }
}
EOF

    # Enable D-Bus services for rich presence
    log_info "Enabling D-Bus services for Discord rich presence..."
    
    # Create systemd user service for Discord RPC
    mkdir -p "$HOME/.config/systemd/user"
    cat > "$HOME/.config/systemd/user/discord-rpc.service" << 'EOF'
[Unit]
Description=Discord Rich Presence RPC Server
After=graphical-session.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'socat TCP-LISTEN:6463,reuseaddr,fork UNIX-CONNECT:/run/user/%i/discord-ipc-0 || true'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical-session.target
EOF

    # Enable the service if user systemd is available
    if systemctl --user show-environment &>/dev/null; then
        systemctl --user enable discord-rpc.service 2>/dev/null || log_warning "Failed to enable discord-rpc user service; you can enable it manually later."
    else
        log_warning "User systemd not available; skipping discord-rpc user service enable."
    fi
    
    # Create Discord activity monitor script
    cat > "$HOME/.local/bin/discord-activity" << 'EOF'
#!/bin/bash
# Discord Activity Monitor for Rich Presence

# Function to get current activity
get_current_activity() {
    local activity=""
    
    # Check if any games are running
    if pgrep -f "steam" > /dev/null; then
        activity="Playing games via Steam"
    elif pgrep -f "lutris" > /dev/null; then
        activity="Gaming with Lutris"
    elif pgrep -f "firefox" > /dev/null; then
        activity="Browsing the web"
    elif pgrep -f "code" > /dev/null; then
        activity="Coding in VS Code"
    else
        activity="Using Arch Linux"
    fi
    
    echo "$activity"
}

# Update Discord rich presence
update_presence() {
    local activity=$(get_current_activity)
    local timestamp=$(date +%s)
    
    # Send rich presence data via IPC
    local rpc_data="{
        \"cmd\": \"SET_ACTIVITY\",
        \"args\": {
            \"pid\": $$,
            \"activity\": {
                \"details\": \"$activity\",
                \"state\": \"On Arch Linux\",
                \"timestamps\": {
                    \"start\": $timestamp
                },
                \"assets\": {
                    \"large_image\": \"discord\",
                    \"large_text\": \"Discord on Linux\"
                }
            }
        },
        \"nonce\": \"$(uuidgen)\"
    }"
    
    # Send to Discord IPC if available
    if [ -S "/run/user/$(id -u)/discord-ipc-0" ]; then
        echo "$rpc_data" | socat - UNIX-CONNECT:/run/user/$(id -u)/discord-ipc-0 2>/dev/null || true
    fi
}

# Main execution
case "${1:-update}" in
    "update")
        update_presence
        ;;
    "monitor")
        while true; do
            update_presence
            sleep 30
        done
        ;;
    *)
        echo "Usage: $0 [update|monitor]"
        exit 1
        ;;
esac
EOF

    chmod +x "$HOME/.local/bin/discord-activity"

    # Create systemd timer for automatic Discord updates (optional)
    mkdir -p "$HOME/.config/systemd/user"
    
    cat > "$HOME/.config/systemd/user/discord-update.service" << 'EOF'
[Unit]
Description=Update Discord Flatpak
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update --noninteractive com.discordapp.Discord
EOF

    cat > "$HOME/.config/systemd/user/discord-update.timer" << 'EOF'
[Unit]
Description=Update Discord daily
Requires=discord-update.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Enable the timer (user can disable if they don't want auto-updates)
    if systemctl --user show-environment &>/dev/null; then
        systemctl --user enable discord-update.timer 2>/dev/null || log_warning "Failed to enable discord-update timer; you can enable it manually later."
    else
        log_warning "User systemd not available; skipping discord-update.timer enable."
    fi
    
    log_success "Discord configuration completed"
    log_info "Discord Flatpak will auto-update and support screensharing"
    log_info "Manual update: run 'update-discord' or 'flatpak update com.discordapp.Discord'"
}

# Configure Telegram auto-update via Flatpak (optional, similar to Discord)
configure_telegram_updates() {
    log_info "Configuring Telegram Flatpak auto-update (optional)..."

    # Ensure Telegram Flatpak is installed
    if ! flatpak list | grep -q "org.telegram.desktop"; then
        log_warning "Telegram Flatpak not found; skipping Telegram auto-update configuration."
        return 0
    fi

    mkdir -p "$HOME/.config/systemd/user"

    cat > "$HOME/.config/systemd/user/telegram-update.service" << 'EOF'
[Unit]
Description=Update Telegram Flatpak
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update --noninteractive org.telegram.desktop
EOF

    cat > "$HOME/.config/systemd/user/telegram-update.timer" << 'EOF'
[Unit]
Description=Update Telegram daily
Requires=telegram-update.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Enable the timer (user can disable if they don't want auto-updates)
    if systemctl --user show-environment &>/dev/null; then
        systemctl --user enable telegram-update.timer 2>/dev/null || log_warning "Failed to enable telegram-update timer; you can enable it manually later."
    else
        log_warning "User systemd not available; skipping telegram-update.timer enable."
    fi

    log_success "Telegram auto-update configuration completed (via Flatpak)"
    log_info "Manual update: run 'flatpak update org.telegram.desktop'"
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
    
    # Enable and start xdg-desktop-portal for screensharing (only if user systemd is available)
    if systemctl --user show-environment &>/dev/null; then
        systemctl --user enable xdg-desktop-portal.service 2>/dev/null || log_warning "Failed to enable xdg-desktop-portal user service; you may need to enable it manually."
        systemctl --user enable xdg-desktop-portal-wlr.service 2>/dev/null || log_warning "Failed to enable xdg-desktop-portal-wlr user service; you may need to enable it manually."
    else
        log_warning "User systemd is not available in this session; skipping xdg-desktop-portal user service configuration."
    fi
    
    log_success "System services configured"
}

# Main execution function
main() {
    log_info "Starting Arch Linux post-installation script..."
    log_info "This script is optimized for AMD Ryzen 5700X and RX 6600 XT"
    echo
    
    # Display disclaimer and get user consent
    log_warning "IMPORTANT DISCLAIMER:"
    echo "This script will make significant changes to your system including:"
    echo "  - Installing packages and AUR helpers"
    echo "  - Modifying system configurations"
    echo "  - Changing Flatpak permissions"
    echo "  - Creating desktop entries and system files"
    echo "  - Enabling services and repositories"
    echo
    log_warning "THE AUTHOR IS NOT RESPONSIBLE FOR:"
    echo "  - Data loss or system damage"
    echo "  - Hardware issues or incompatibilities"
    echo "  - Software conflicts or malfunctions"
    echo "  - Any other consequences of running this script"
    echo
    log_info "This script is provided AS-IS with NO WARRANTY."
    log_info "You use it entirely AT YOUR OWN RISK."
    echo
    read -p "Do you understand and accept these risks? Type 'I ACCEPT' to continue: " user_consent
    
    if [ "$user_consent" != "I ACCEPT" ]; then
        log_info "Script execution cancelled by user."
        log_info "No changes have been made to your system."
        exit 0
    fi
    
    log_success "User consent acknowledged. Proceeding with installation..."
    echo
    
    # Run all checks
    check_root
    preflight_checks
    check_internet
    
    # System setup
    update_system
    install_amd_support
    
    # Package installation
    install_aura
    install_arch_packages
    install_1password
    install_aur_packages
    setup_flatpak
    
    # Final configuration
    configure_services
    configure_discord
    configure_telegram
    configure_telegram_updates
    
    echo
    log_success "Installation completed successfully!"
    log_info "Please reboot your system to ensure all changes take effect."
    echo
    log_info "After reboot, you may want to:"
    log_info "  - Configure your desktop environment"  
    log_info "  - Set up your user preferences"
    log_info "  - Test gaming performance with your AMD setup"
    log_info "  - Run 'systemctl --user enable pipewire pipewire-pulse' for audio"
    echo
    log_info "Discord Setup (Flatpak with Auto-Updates):"
    log_info "  - Use 'Discord (Screenshare & Auto-Update)' from your application menu"
    log_info "  - Auto-updates daily via systemd timer (can be disabled if preferred)"
    log_info "  - Manual update: run 'update-discord' or 'flatpak update com.discordapp.Discord'"
    log_info "  - Screensharing and audio/video calls work out of the box"
    log_info "  - No more update errors - Flatpak handles updates seamlessly"
    echo
    log_info "1Password Setup:"
    log_info "  - Launch 1Password and sign in to your account"
    log_info "  - Browser integration is pre-configured for Firefox, Chrome, and Chromium"
    log_info "  - Use Ctrl+Shift+Space for quick access from anywhere"
    log_info "  - Updates: Run 'aura -Au' to update AUR packages including 1Password"
    echo
    log_info "Telegram Integration:"
    log_info "  - Use 'Telegram (System Integrated)' from your application menu"
    log_info "  - Automatically starts in system tray on login (can be disabled)"
    log_info "  - Full system notifications, file handling, and tray integration"
    log_info "  - Updates: 'flatpak update org.telegram.desktop' or rely on the optional daily auto-update timer"
    log_info "  - Supports tg:// URLs and native file associations"
    echo
}

# Run main function
main "$@"
