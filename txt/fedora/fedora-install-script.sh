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
    sudo dnf install -y wget curl git vim gcc make dkms bat fzf tmux zsh sed findutils nnn htop NetworkManager-tui ncdu mc playerctl libnotify xdotool yt-dlp btop git-lfs neovim || handle_error "Installing essential tools"
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

    log "Installing AMD CPU/GPU firmwares and additional device firmwares..."
    sudo dnf install -y linux-firmware amd-ucode-firmware amd-gpu-firmware || handle_error "Installing AMD firmwares"
    sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware" || handle_error "Installing various tainted firmwares"
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
install_additional_apps() {
    log "Enabling Copr repositories for LACT and Prism Launcher..."
    sudo dnf copr enable -y ilyaz/LACT || log "Failed to enable LACT Copr repository"
    sudo dnf copr enable -y g3tchoo/prismlauncher || log "Failed to enable Prism Launcher Copr repository"

    log "Installing additional applications..."
    sudo dnf install -y libreoffice lutris krita blender steam gimp obs-studio kdenlive vlc audacity dnfdragora-gui dnfdragora bleachbit firefox discord telegram-desktop keepassxc thunderbird handbrake lact qbittorrent prismlauncher || handle_error "Installing additional applications"

    log "Enabling lactd service..."
    sudo systemctl enable --now lactd || log "Failed to enable lactd service"
}

# Function to install gaming-focused tools and dependencies
install_gaming_tools() {
    log "Installing gaming performance tools and dependencies..."
    sudo dnf install -y gamemode gamemode-devel gamescope mangohud goverlay protontricks wine winetricks steam-devices vulkan-loader vulkan-loader.i686 mesa-vulkan-drivers mesa-vulkan-drivers.i686 vkbasalt vkbasalt.i686 corectrl vulkan-tools || handle_error "Installing gaming performance tools"

    log "Enabling gamemoded user service..."
    systemctl --user enable --now gamemoded.service 2>/dev/null || log "gamemoded user service not found or already running."

    log "Installing gaming Flatpaks (Heroic, Bottles, ProtonUp-Qt)..."
    sudo flatpak install -y flathub com.heroicgameslauncher.hgl com.usebottles.bottles net.davidotek.pupgui2 || log "Failed to install some gaming Flatpaks."
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

# Function to install fonts and emoji support
install_fonts_and_emoji() {
    log "Installing fonts and emoji..."
    sudo dnf install -y google-noto-color-emoji-fonts google-noto-sans-fonts google-noto-serif-fonts \
        fira-code-fonts cascadia-code-fonts jetbrains-mono-fonts \
        curl cabextract fontconfig || handle_error "Installing core fonts"

    local ms_fonts_dir="/home/calebowolf/fonts"
    local dest_fonts_dir="/usr/share/fonts/microsoft"
    if [ -d "$ms_fonts_dir" ]; then
        log "Installing Microsoft fonts from $ms_fonts_dir..."
        sudo mkdir -p "$dest_fonts_dir"
        sudo cp -r "$ms_fonts_dir/." "$dest_fonts_dir/" || log "Failed to copy Microsoft fonts."
        sudo find "$dest_fonts_dir" -type d -exec chmod 755 {} +
        sudo find "$dest_fonts_dir" -type f -exec chmod 644 {} +
        sudo fc-cache -f || log "Failed to update font cache."
    else
        log "Microsoft fonts directory not found at $ms_fonts_dir. Skipping custom font installation."
    fi
}

# Function to perform final cleanup
final_cleanup() {
    log "Performing final system update and cleanup..."
    sudo dnf update -y || handle_error "Final system update"
    sudo dnf autoremove -y || handle_error "Autoremove unused packages"
    sudo dnf clean all || log "Failed to clean DNF cache"
    sudo flatpak update -y || handle_error "Updating Flatpak applications"
    flatpak uninstall --unused -y || log "Failed to remove unused Flatpak dependencies"

    log "Enabling weekly SSD TRIM timer..."
    sudo systemctl enable --now fstrim.timer || log "Failed to enable fstrim.timer"

    log "Enabling pcscd socket for Smart Cards/Security Keys..."
    sudo systemctl enable --now pcscd.socket || log "Failed to enable pcscd.socket"

    log "Enabling monthly BTRFS scrub timer for root filesystem..."
    sudo systemctl enable --now btrfs-scrub@-.timer || log "Failed to enable btrfs-scrub@-.timer"
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
install_additional_apps
install_gaming_tools
install_rpm_packages
install_fonts_and_emoji
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
Copyright © 2026 CalebOWolf/Caleb Mignano. All rights reserved.
