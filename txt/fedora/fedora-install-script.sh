#!/bin/bash
# Fedora Installation Script for AMD Ryzen 5700X and AMD Radeon RX 6600 XT
# This script sets up the system with essential tools, drivers, and applications for general use, gaming, and content creation.
# Suggestions for improvement can be made on GitHub: CalebOWolf/wolf-howl/fedora-setup-script
#
# DISCLAIMER:
# This script is provided "AS IS" without any warranties or guarantees. The author assumes no responsibility for any data loss, irreversible changes, or damage to your system resulting from the use of this script. Use it at your own risk and ensure you have proper backups before proceeding.

# --- Confirmation Prompt ---
echo "--------------------------------------------------------------------------------"
echo "DISCLAIMER:"
echo "This script is provided 'AS IS' without any warranties or guarantees."
echo "The author assumes no responsibility for any data loss, irreversible changes,"
echo "or damage to your system resulting from the use of this script."
echo "Please ensure you have proper backups before proceeding."
echo "--------------------------------------------------------------------------------"
read -p "Do you agree to the disclaimer and wish to proceed? (y/n) " -n 1 -r
echo # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted by user."
    exit 1
fi
echo "Agreement confirmed. Starting setup..."
echo # Adding a blank line for readability before the logs start.

# Constants
LOG_FILE="fedora-setup.log"

# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Error handling
handle_error() {
    log "Error occurred during: $1"
    exit 1
}

# Function to enable sudo password feedback (asterisks while typing)
enable_sudo_pwfeedback() {
    log "Enabling sudo password feedback..."
    local sudoers_file="/etc/sudoers.d/00-pwfeedback"

    if sudo grep -q "Defaults pwfeedback" "$sudoers_file" 2>/dev/null; then
        log "sudo password feedback already enabled."
        return
    fi

    echo "Defaults pwfeedback" | sudo tee "$sudoers_file" >/dev/null || handle_error "Writing sudo pwfeedback configuration"
    sudo chmod 440 "$sudoers_file" || handle_error "Setting permissions on sudo pwfeedback configuration"
    sudo visudo -cf "$sudoers_file" || handle_error "Validating sudo pwfeedback configuration"
}

# System
# Function to update the system
update_system() {
    log "Updating the system..."
    sudo dnf update -y && sudo dnf upgrade -y || handle_error "System update"
    sudo dnf install -y dnf-plugins-core kernel-devel kernel-headers || handle_error "Installing essential packages"
}

# Essential Tools
# Function to install essential tools
install_essential_tools() {
    log "Installing essential tools..."
    sudo dnf install -y wget curl git vim gcc make dkms bat fzf tmux zsh sed findutils nnn htop NetworkManager-tui ncdu mc playerctl libnotify xdotool yt-dlp || handle_error "Installing essential tools"
}

# Function to enable RPM Fusion
enable_rpm_fusion() {
    log "Enabling RPM Fusion..."
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm || handle_error "Enabling RPM Fusion"
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || handle_error "Enabling RPM Fusion"
    sudo dnf update -y || handle_error "Updating after enabling RPM Fusion"
}

# Function to enable RPM Fusion Tainted repository
enable_rpmfusion_tainted() {
    log "Enabling RPM Fusion Tainted repository..."
    sudo dnf install -y rpmfusion-free-release-tainted || handle_error "Enabling RPM Fusion Tainted repository"
}

# Function to install RPM Fusion AppStream metadata
install_rpmfusion_appstream_data() {
    log "Installing RPM Fusion AppStream metadata..."
    sudo dnf install -y rpmfusion-*-appstream-data || handle_error "Installing RPM Fusion AppStream metadata"
}

# Function to enable Cisco OpenH264 repository
enable_cisco_openh264() {
    log "Enabling Cisco OpenH264 repository..."
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1 || handle_error "Enabling Cisco OpenH264 repository"
}

# Function to install AMD Radeon drivers
install_amd_drivers() {
    log "Installing AMD Radeon drivers..."
    sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld || handle_error "Swapping mesa-va-drivers"
    sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld || handle_error "Swapping mesa-vdpau-drivers"
}

# Function to swap ffmpeg-free with ffmpeg
swap_ffmpeg() {
    log "Swapping ffmpeg-free with ffmpeg..."
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || handle_error "Swapping ffmpeg-free with ffmpeg"
}

# Function to swap 32-bit mesa drivers
swap_32bit_mesa_drivers() {
    log "Swapping 32-bit mesa drivers..."
    if dnf list --available mesa-va-drivers.i686 >/dev/null 2>&1 && dnf list --available mesa-va-drivers-freeworld.i686 >/dev/null 2>&1; then
        sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686 || handle_error "Swapping mesa-va-drivers.i686"
    else
        log "Skipping mesa-va-drivers.i686 swap (packages not available)"
    fi

    if dnf list --available mesa-vdpau-drivers.i686 >/dev/null 2>&1 && dnf list --available mesa-vdpau-drivers-freeworld.i686 >/dev/null 2>&1; then
        sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686 || handle_error "Swapping mesa-vdpau-drivers.i686"
    else
        log "Skipping mesa-vdpau-drivers.i686 swap (packages not available)"
    fi
}

# Function to update multimedia packages
update_multimedia_packages() {
    log "Updating multimedia packages..."
    sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin || handle_error "Updating multimedia packages"
}

# Function to install multimedia codecs
install_multimedia_codecs() {
    log "Installing multimedia codecs..."
    sudo dnf install -y gstreamer1-plugins-base gstreamer1-plugins-good-extras gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free-extras gstreamer1-plugins-ugly gstreamer1-libav lame ffmpeg libdvdcss vlc || handle_error "Installing multimedia codecs"
}

# Function to install libdvdcss
install_libdvdcss() {
    log "Installing libdvdcss..."
    sudo dnf install -y libdvdcss || handle_error "Installing libdvdcss"
}

# Function to install various firmwares
install_firmwares() {
    log "Enabling RPM Fusion Nonfree Tainted repository..."
    sudo dnf install -y rpmfusion-nonfree-release-tainted || handle_error "Enabling RPM Fusion Nonfree Tainted repository"

    log "Installing various firmwares..."
    sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware" || handle_error "Installing various firmwares"
}

# Function to optimize AMD Ryzen
optimize_amd_ryzen() {
    log "Optimizing AMD Ryzen..."
    sudo dnf install -y tuned kernel-tools || handle_error "Installing AMD Ryzen performance tools"
    sudo systemctl enable tuned || handle_error "Enabling tuned service"
    sudo systemctl start tuned || handle_error "Starting tuned service"
    sudo tuned-adm profile latency-performance || handle_error "Setting tuned profile"
    if command -v cpupower >/dev/null 2>&1; then
        if cpupower frequency-info >/dev/null 2>&1; then
            # Attempt to set performance governor; if unsupported, just log and continue
            if ! sudo cpupower frequency-set -g performance >/dev/null 2>&1; then
                log "cpupower couldn't set performance governor (likely using amd_pstate_epp); skipping."
            fi
        else
            log "cpupower frequency-info not supported on this platform; skipping governor change."
        fi
    else
        log "cpupower not found; skipping governor change."
    fi
}

# Function to install Flatpak and applications
setup_flatpak() {
    log "Setting up Flatpak..."
    sudo dnf install -y flatpak || handle_error "Installing Flatpak"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || handle_error "Adding Flathub repository"
    flatpak update -y || handle_error "Updating Flatpak"
}

# Function to install additional applications
# install_additional_apps() {
    # log "Installing additional applications..."
    # sudo dnf install -y libreoffice lutris krita blender steam gimp obs-studio kdenlive vlc audacity dnfdragora-gui dnfdragora || handle_error "Installing additional applications"
# }

# Function to install gaming-focused tools and dependencies
install_gaming_tools() {
    log "Installing gaming performance tools and dependencies..."
    sudo dnf install -y gamemode gamemode-devel gamescope mangohud goverlay protontricks wine winetricks steam-devices vulkan-loader vulkan-loader.i686 mesa-vulkan-drivers mesa-vulkan-drivers.i686 || handle_error "Installing gaming performance tools"
}

# Function to install specific RPM packages
install_rpm_packages() {
    log "Installing specific RPM packages..."
    log "Configuring Visual Studio Code repository..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || handle_error "Importing Microsoft GPG key"

    sudo tee /etc/yum.repos.d/vscode.repo >/dev/null <<'EOF' || handle_error "Creating VS Code repository"
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
repo_gpgcheck=1
repo_gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

    log "Installing Visual Studio Code..."
    sudo dnf install -y code || handle_error "Installing Visual Studio Code"

}

# Function to perform final cleanup
final_cleanup() {
    log "Performing final system update and cleanup..."
    sudo dnf update -y || handle_error "Final system update"
    sudo dnf autoremove -y || handle_error "Autoremove unused packages"
    sudo flatpak update -y || handle_error "Updating Flatpak applications"
}

# Main script execution
log "Starting Fedora installation and setup script..."
update_system
install_essential_tools
enable_sudo_pwfeedback
enable_rpm_fusion
enable_rpmfusion_tainted
install_rpmfusion_appstream_data
enable_cisco_openh264
install_amd_drivers
swap_ffmpeg
swap_32bit_mesa_drivers
update_multimedia_packages
install_multimedia_codecs
install_libdvdcss
install_firmwares
optimize_amd_ryzen
setup_flatpak
#install_additional_apps
install_gaming_tools
install_rpm_packages
final_cleanup

log "Fedora installation and setup script completed."
read -p "Installation complete. Reboot the system now? (y/n): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    log "Rebooting the system..."
    sleep 5
    sudo reboot
else
    log "Reboot skipped. Please reboot manually to apply changes."
fi

# End of the script
Copyright © 2025 CalebOWolf/Caleb Mignano. All rights reserved.
