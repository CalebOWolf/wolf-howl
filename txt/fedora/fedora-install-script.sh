#!/bin/bash
# =============================================================================
# Fedora Installation Script with Error Handling
# =============================================================================
# Author: CalebOWolf/Caleb Mignano
# Purpose: Automated Fedora setup for AMD Ryzen 5700X and RX 6600 XT systems
# Version: 2.0 (With comprehensive error handling)
#
# This script will:
# - Setup CPU and GPU drivers and optimizations
# - Install essential development tools and applications
# - Configure multimedia codecs and gaming libraries
# - Install applications via both RPM and Flatpak
# - Optimize system performance for gaming and content creation
#
# REQUIREMENTS:
# - Fresh or existing Fedora installation
# - User account with sudo privileges
# - Active internet connection
# - At least 8GB free disk space
#
# DISCLAIMER:
# This script modifies system configurations. While tested, use at your own risk.
# Always backup important data before running system modification scripts.
#
# Report issues: https://github.com/CalebOWolf/wolf-howl/issues
# =============================================================================

# Script configuration
set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'       # Secure Internal Field Separator

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Script metadata
readonly SCRIPT_NAME="Fedora Setup Script"
readonly SCRIPT_VERSION="2.0"
readonly LOG_FILE="/tmp/fedora-setup-$(date +%Y%m%d-%H%M%S).log"
readonly ERROR_COUNT_FILE="/tmp/fedora-setup-errors"

# Initialize error counter
echo "0" > "$ERROR_COUNT_FILE"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Info message function
info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

# Success message function
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "$LOG_FILE"
}

# Warning message function
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "$LOG_FILE"
}

# Error message function
error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
    # Increment error counter
    local count
    count=$(cat "$ERROR_COUNT_FILE")
    echo $((count + 1)) > "$ERROR_COUNT_FILE"
}

# Critical error function (exits script)
critical_error() {
    error "$*"
    error "Critical error encountered. Script execution stopped."
    show_log_location
    exit 1
}

# Show log file location
show_log_location() {
    info "Full log available at: $LOG_FILE"
}

# Command execution with error handling
execute_command() {
    local cmd="$1"
    local description="${2:-Executing command}"
    local allow_failure="${3:-false}"
    
    info "$description..."
    log "Executing: $cmd"
    
    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        success "$description completed successfully"
        return 0
    else
        local exit_code=$?
        if [[ "$allow_failure" == "true" ]]; then
            warning "$description failed (exit code: $exit_code) - continuing anyway"
            return 0
        else
            error "$description failed (exit code: $exit_code)"
            return $exit_code
        fi
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check system requirements
check_requirements() {
    info "Checking system requirements..."
    
    # Check if running on Fedora
    if ! grep -q "Fedora" /etc/os-release 2>/dev/null; then
        critical_error "This script is designed for Fedora Linux only"
    fi
    
    # Check sudo privileges
    if ! sudo -n true 2>/dev/null; then
        critical_error "This script requires sudo privileges. Run with a user that has sudo access."
    fi
    
    # Check internet connection
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        critical_error "Internet connection required but not available"
    fi
    
    # Check available disk space (require at least 8GB free in root)
    local available_space
    available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 8388608 ]]; then  # 8GB in KB
        critical_error "Insufficient disk space. At least 8GB free space required in root filesystem"
    fi
    
    success "System requirements check passed"
}

# User confirmation prompt
confirm_action() {
    local prompt="$1"
    local default="${2:-n}"
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$prompt [Y/n]: " yn
            yn=${yn:-y}
        else
            read -p "$prompt [y/N]: " yn
            yn=${yn:-n}
        fi
        
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Show script header
show_header() {
    echo -e "${CYAN}"
    echo "==============================================================================="
    echo "  $SCRIPT_NAME v$SCRIPT_VERSION"
    echo "  Automated Fedora setup for AMD Ryzen systems"
    echo "==============================================================================="
    echo -e "${NC}"
    
    info "Starting Fedora installation and setup script..."
    info "Log file: $LOG_FILE"
}

# =============================================================================
# MAIN INSTALLATION FUNCTIONS
# =============================================================================

# Enable RPM Fusion repositories
setup_rpm_fusion() {
    info "Setting up RPM Fusion repositories..."
    
    local fedora_version
    fedora_version=$(rpm -E %fedora)
    
    local free_repo="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm"
    local nonfree_repo="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"
    
    execute_command "sudo dnf install -y $free_repo $nonfree_repo" "Installing RPM Fusion repositories"
    execute_command "sudo dnf config-manager --set-enabled fedora-cisco-openh264" "Enabling Cisco OpenH264"
    execute_command "sudo dnf update -y @core" "Updating core packages"
}

# Update system packages
update_system() {
    info "Updating system packages..."
    
    execute_command "sudo dnf update -y" "Updating all packages"
    execute_command "sudo dnf upgrade -y" "Upgrading system"
    execute_command "sudo dnf install -y dnf-plugins-core kernel-devel kernel-headers" "Installing essential system packages"
}

# Install development tools and utilities
install_essential_tools() {
    info "Installing essential development tools and utilities..."
    
    local essential_packages=(
        "wget" "curl" "git" "vim" "gcc" "make" "dkms"
        "bat" "fzf" "tmux" "zsh" "sed" "xargs" "nnn"
        "htop" "nmtui" "ncdu" "cmus" "mc" "playerctl"
        "notify-send" "xdotool" "youtube-dl"
    )
    
    local package_list
    package_list=$(IFS=' '; echo "${essential_packages[*]}")
    
    execute_command "sudo dnf install -y $package_list" "Installing essential tools"
}

# Setup AMD graphics drivers
setup_amd_drivers() {
    info "Setting up AMD Radeon drivers..."
    
    # Check if RPM Fusion is available
    if ! dnf repolist | grep -q rpmfusion; then
        warning "RPM Fusion not detected. Setting up first..."
        setup_rpm_fusion
    fi
    
    execute_command "sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld" "Swapping VA drivers"
    execute_command "sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld" "Swapping VDPAU drivers"
    execute_command "sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686" "Swapping 32-bit VA drivers" true
    execute_command "sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686" "Swapping 32-bit VDPAU drivers" true
}

# Install multimedia codecs
install_multimedia_codecs() {
    info "Installing multimedia codecs and media tools..."
    
    local multimedia_packages=(
        "gstreamer1-plugins-base" "gstreamer1-plugins-good-extras"
        "gstreamer1-plugins-good" "gstreamer1-plugins-bad-free"
        "gstreamer1-plugins-bad-free-extras" "gstreamer1-plugins-ugly"
        "gstreamer1-plugins-ugly-free" "gstreamer1-libav" "lame"
        "ffmpeg" "libdvdcss" "libdvdread" "handbrake" "vlc"
        "obs-studio" "simplescreenrecorder"
    )
    
    local package_list
    package_list=$(IFS=' '; echo "${multimedia_packages[*]}")
    
    execute_command "sudo dnf install -y $package_list" "Installing multimedia codecs and tools"
}

# Setup AMD CPU optimization
setup_amd_cpu_optimization() {
    info "Setting up AMD Ryzen CPU optimization..."
    
    execute_command "sudo dnf install -y amd-ucode" "Installing AMD microcode"
    execute_command "sudo dnf install -y tuned cpupower" "Installing performance tuning tools"
    
    # Enable and start tuned service
    execute_command "sudo systemctl enable tuned" "Enabling tuned service"
    execute_command "sudo systemctl start tuned" "Starting tuned service"
    execute_command "sudo tuned-adm profile latency-performance" "Setting performance profile"
    
    # Install temperature monitoring
    execute_command "sudo dnf install -y lm_sensors" "Installing temperature monitoring tools"
    
    # CPU frequency scaling (may fail on some systems, so allow failure)
    execute_command "sudo cpupower frequency-set -g performance" "Setting CPU governor to performance" true
    execute_command "sudo cpupower frequency-set -d 3.4GHz -u 4.6GHz" "Setting CPU frequency limits" true
    
    info "CPU optimization complete. You may need to run 'sudo sensors-detect' manually for temperature monitoring."
}

# Install RGB control software
install_rgb_control() {
    info "Installing RGB control software..."
    
    local openrgb_url="https://openrgb.org/releases/openrgb-0.7-linux-x86_64.rpm"
    
    info "Installing OpenRGB..."
    log "Executing: sudo dnf install -y $openrgb_url"
    
    if sudo dnf install -y "$openrgb_url" >> "$LOG_FILE" 2>&1; then
        success "Installing OpenRGB completed successfully"
    else
        warning "OpenRGB installation failed. You may need to install it manually from https://openrgb.org/"
    fi
}

# Setup Flatpak
setup_flatpak() {
    info "Setting up Flatpak and Flathub repository..."
    
    execute_command "sudo dnf install -y flatpak" "Installing Flatpak"
    execute_command "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" "Adding Flathub repository"
    execute_command "flatpak update -y" "Updating Flatpak applications"
}

# Install additional RPM applications
install_rpm_applications() {
    info "Installing additional RPM applications..."
    
    local rpm_packages=(
        "openssh" "curl" "xorg-x11-font-utils" "fontconfig"
        "libreoffice" "lutris" "krita" "blender" "pavucontrol-qt"
        "bleachbit" "gparted" "steam" "hyfetch" "gimp"
        "kdenlive" "audacity" "ffmpeg"
    )
    
    local package_list
    package_list=$(IFS=' '; echo "${rpm_packages[*]}")
    
    execute_command "sudo dnf install -y $package_list" "Installing additional RPM applications"
}

# Install 32-bit libraries for gaming compatibility
install_32bit_libraries() {
    info "Installing 32-bit libraries for gaming compatibility..."
    
    local lib32_packages=(
        "glibc.i686" "libstdc++.i686" "zlib.i686" "libX11.i686"
        "libXext.i686" "libXrender.i686" "libXrandr.i686" "libXcursor.i686"
        "libXfixes.i686" "libXi.i686" "libXdamage.i686" "libXcomposite.i686"
        "libXtst.i686" "libSM.i686" "libICE.i686" "libGL.i686"
        "libGLU.i686" "mesa-libGL.i686" "mesa-libGLU.i686" "libdrm.i686"
        "libdbus-glib-1.i686" "alsa-lib.i686" "pulseaudio-libs.i686"
        "cups-libs.i686" "libvdpau.i686" "libva.i686" "freetype.i686"
        "fontconfig.i686" "libpng.i686" "libjpeg-turbo.i686"
    )
    
    local package_list
    package_list=$(IFS=' '; echo "${lib32_packages[*]}")
    
    execute_command "sudo dnf install -y $package_list" "Installing 32-bit compatibility libraries"
}

# Download and install external RPM packages
install_external_rpms() {
    info "Installing external applications via RPM packages..."
    
    # Create temporary directory
    local temp_dir="/tmp/fedora-setup-rpms"
    mkdir -p "$temp_dir"
    
    # Install 1Password
    install_1password() {
        info "Installing 1Password..."
        local rpm_file="$temp_dir/1password.rpm"
        
        if execute_command "wget -O '$rpm_file' 'https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm'" "Downloading 1Password RPM"; then
            execute_command "sudo dnf install -y '$rpm_file'" "Installing 1Password" true
            rm -f "$rpm_file"
        else
            warning "Failed to download 1Password. Skipping..."
        fi
    }
    
    # Install Google Chrome
    install_chrome() {
        info "Installing Google Chrome..."
        local rpm_file="$temp_dir/google-chrome.rpm"
        
        if execute_command "wget -O '$rpm_file' 'https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm'" "Downloading Google Chrome RPM"; then
            execute_command "sudo dnf install -y '$rpm_file'" "Installing Google Chrome" true
            rm -f "$rpm_file"
        else
            warning "Failed to download Google Chrome. Skipping..."
        fi
    }
    
    # Install Visual Studio Code
    install_vscode() {
        info "Installing Visual Studio Code..."
        local rpm_file="$temp_dir/vscode.rpm"
        
        if execute_command "wget -O '$rpm_file' 'https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64'" "Downloading VS Code RPM"; then
            execute_command "sudo dnf install -y '$rpm_file'" "Installing Visual Studio Code" true
            rm -f "$rpm_file"
        else
            warning "Failed to download VS Code. Skipping..."
        fi
    }
    
    # Install FS Voice dependencies (for voice communication)
    install_fs_voice_deps() {
        info "Installing FS Voice dependencies..."
        local fs_voice_packages=(
            "libstdc++.i686" "libidn2.i686" "gstreamer1-plugins-bad-free.i686"
            "gstreamer1-plugins-bad-free-extras.i686" "gstreamer1-plugins-base.i686"
            "gstreamer1-plugins-good.i686" "gstreamer1-plugins-good-extras.i686"
            "gstreamer1-plugins-ugly.i686" "gstreamer1-plugins-ugly-free.i686"
            "libuuid.i686" "libzip.i686" "alsa-plugins-pulseaudio.i686"
        )
        
        local package_list
        package_list=$(IFS=' '; echo "${fs_voice_packages[*]}")
        
        execute_command "sudo dnf install -y $package_list" "Installing FS Voice dependencies" true
    }
    
    # Run installation functions
    install_1password
    install_chrome
    install_vscode
    install_fs_voice_deps
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
}

# Install Flatpak applications
install_flatpak_applications() {
    info "Installing Flatpak applications..."
    
    # Define application categories for better organization
    local communication_apps=(
        "com.discordapp.Discord"
        "org.telegram.desktop"
    )
    
    local gaming_apps=(
        "org.firestormviewer.FirestormViewer"
        "org.prismlauncher.PrismLauncher"
        "io.mgba.mGBA"
        "sh.ppy.osu"
        "org.ppsspp.PPSSPP"
        "com.vysp3r.ProtonPlus"
        "net.davidotek.pupgui2"
        "net.rpcs3.RPCS3"
        "app.twintaillauncher.ttl"
        "com.usebottles.bottles"
        "io.github.fastrizwaan.WineZGUI"
    )
    
    local utility_apps=(
        "io.github.shiftey.Desktop"
        "com.github.joseexposito.touche"
        "org.nickvision.tubeconverter"
        "org.qbittorrent.qBittorrent"
        "com.transmissionbt.Transmission"
        "org.remmina.Remmina"
        "com.github.unrud.VideoDownloader"
        "org.keepassxc.KeePassXC"
        "org.localsend.localsend_app"
        "org.x.Warpinator"
        "com.github.tchx84.Flatseal"
        "it.mijorus.gearlever"
        "org.gnome.DiskUtility"
    )
    
    local creative_apps=(
        "org.audacityteam.Audacity"
        "com.rafaelmardojai.Blanket"
        "io.github.celluloid_player.Celluloid"
        "com.obsproject.Studio"
        "fr.handbrake.ghb"
        "org.kde.kdenlive"
    )
    
    local system_apps=(
        "de.haeckerfelix.Shortwave"
        "io.github.arunsivaramanneo.GPUViewer"
        "io.gitlab.adhami3310.Impression"
        "io.github.ilya_zlobintsev.LACT"
        "io.github.wivrn.wivrn"
    )
    
    # Install applications by category
    install_flatpak_category() {
        local category_name="$1"
        shift
        local apps=("$@")
        
        info "Installing $category_name applications..."
        
        for app in "${apps[@]}"; do
            execute_command "flatpak install -y flathub '$app'" "Installing $app" true
        done
    }
    
    # Install all categories
    install_flatpak_category "communication" "${communication_apps[@]}"
    install_flatpak_category "gaming" "${gaming_apps[@]}"
    install_flatpak_category "utility" "${utility_apps[@]}"
    install_flatpak_category "creative" "${creative_apps[@]}"
    install_flatpak_category "system" "${system_apps[@]}"
}

# Perform final system cleanup and updates
final_system_cleanup() {
    info "Performing final system update and cleanup..."
    
    execute_command "sudo dnf update -y" "Final system update"
    execute_command "sudo dnf autoremove -y" "Removing unused packages"
    execute_command "flatpak update -y" "Updating Flatpak applications"
    
    # Clear package cache to free up space
    execute_command "sudo dnf clean all" "Cleaning package cache" true
    
    success "System cleanup completed"
}

# Generate installation report
generate_report() {
    local error_count
    error_count=$(cat "$ERROR_COUNT_FILE" 2>/dev/null || echo "0")
    
    echo
    echo -e "${CYAN}===============================================================================${NC}"
    echo -e "${WHITE}  INSTALLATION REPORT${NC}"
    echo -e "${CYAN}===============================================================================${NC}"
    
    if [[ "$error_count" -eq 0 ]]; then
        echo -e "${GREEN}✅ Installation completed successfully with no errors!${NC}"
    elif [[ "$error_count" -lt 5 ]]; then
        echo -e "${YELLOW}⚠️  Installation completed with $error_count minor errors${NC}"
        echo -e "${YELLOW}   Check the log file for details: $LOG_FILE${NC}"
    else
        echo -e "${RED}❌ Installation completed with $error_count errors${NC}"
        echo -e "${RED}   Please review the log file: $LOG_FILE${NC}"
    fi
    
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Reboot your system to ensure all changes take effect"
    echo "2. Run 'sudo sensors-detect' to set up temperature monitoring"
    echo "3. Check 'cpupower frequency-info' to verify CPU scaling"
    echo "4. Test installed applications and configurations"
    echo
    echo -e "${WHITE}Log file location: $LOG_FILE${NC}"
    echo -e "${CYAN}===============================================================================${NC}"
}

# Main script execution
main() {
    # Initialize
    show_header
    check_requirements
    
    # Show disclaimer and get user confirmation
    echo
    warning "IMPORTANT DISCLAIMER:"
    echo "This script will modify your system configuration and install numerous applications."
    echo "While tested, it may not work perfectly on all systems."
    echo "Please ensure you have:"
    echo "  - A backup of important data"
    echo "  - A stable internet connection"
    echo "  - At least 8GB of free disk space"
    echo
    
    if ! confirm_action "Do you want to proceed with the installation?"; then
        info "Installation cancelled by user"
        exit 0
    fi
    
    # Main installation steps
    info "Starting installation process..."
    
    update_system
    setup_rpm_fusion
    install_essential_tools
    setup_amd_drivers
    install_multimedia_codecs
    setup_amd_cpu_optimization
    install_rgb_control
    install_rpm_applications
    install_32bit_libraries
    install_external_rpms
    setup_flatpak
    install_flatpak_applications
    final_system_cleanup
    
    # Generate report
    generate_report
    
    # Ask about reboot
    echo
    if confirm_action "Installation complete. Reboot now to ensure all changes take effect?" "y"; then
        info "Rebooting system in 5 seconds..."
        sleep 5
        sudo reboot
    else
        info "Please remember to reboot your system later to ensure all changes take effect."
    fi
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Trap cleanup on exit
cleanup() {
    rm -f "$ERROR_COUNT_FILE" 2>/dev/null || true
}
trap cleanup EXIT

# Run main function
main "$@"

# =============================================================================
# Copyright © 2025 CalebOWolf/Caleb Mignano. All rights reserved.
# =============================================================================