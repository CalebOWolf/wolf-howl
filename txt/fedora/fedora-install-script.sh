#!/bin/bash
# Fedora Installation Script for AMD Ryzen 5700X and AMD Radeon RX 6600 XT
# This script sets up the system with essential tools, drivers, and applications for general use, gaming, and content creation.
# Suggestions for improvement can be made on GitHub: CalebOWolf/wolf-howl/fedora-setup-script
#
# DISCLAIMER:
# This script is provided "AS IS" without any warranties or guarantees. The author assumes no responsibility for any data loss, irreversible changes, or damage to your system resulting from the use of this script. Use it at your own risk and ensure you have proper backups before proceeding.

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

# Function to update the system
update_system() {
    log "Updating the system..."
    sudo dnf update -y && sudo dnf upgrade -y || handle_error "System update"
    sudo dnf install -y dnf-plugins-core kernel-devel kernel-headers || handle_error "Installing essential packages"
}

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
install_additional_apps() {
    log "Installing additional applications..."
    sudo dnf install -y libreoffice lutris krita blender steam gimp obs-studio kdenlive vlc audacity || handle_error "Installing additional applications"
}

# Helper to copy MS Sans Serif fonts from Windows or user-provided directories
install_ms_sans_serif_fonts() {
    log "Checking for MS Sans Serif font files..."
    local mssans_dest="$HOME/.local/share/fonts/MSSansSerif"
    mkdir -p "$mssans_dest"
    local found="false"

    shopt -s nullglob
    local candidate_dirs=(
        "$HOME/MSSansFonts"
        "$HOME/Fonts/MSSans"
        /mnt/c/Windows/Fonts
        /run/media/$USER/*/Windows/Fonts
    )
    shopt -u nullglob

    for source in "${candidate_dirs[@]}"; do
        if [ -d "$source" ]; then
            log "Scanning $source for MS Sans Serif fonts in $source..."
            while IFS= read -r -d '' font_file; do
                cp -f "$font_file" "$mssans_dest"/
                found="true"
            done < <(find "$source" -maxdepth 1 -type f \( -iname "sserife.ttf" -o -iname "sserif.ttf" -o -iname "micross.ttf" -o -iname "*mssans*.ttf" \) -print0 2>/dev/null)
        fi
    done

    if [ "$found" = "true" ]; then
        log "MS Sans Serif fonts copied to $mssans_dest"
        fc-cache -f "$mssans_dest" || log "Warning: failed to refresh MS Sans Serif font cache"
    else
        log "MS Sans Serif fonts not found. Mount your Windows partition or place micross.ttf / sserif*.ttf files in $HOME/MSSansFonts and rerun to enable KDE MS Sans Serif defaults."
    fi
}

# Function to install fonts and emoji support
install_fonts_and_emoji() {
    log "Installing fonts and emoji packages..."
    sudo dnf install -y google-noto-fonts google-noto-sans-cjk-ttc-fonts google-noto-serif-cjk-ttc-fonts jetbrains-mono-fonts fira-code-fonts ibm-plex-mono-fonts dejavu-sans-mono-fonts adobe-source-code-pro-fonts mozilla-fira-sans-fonts google-noto-emoji-color-fonts mozilla-twemoji-colr-fonts cabextract || handle_error "Installing font and emoji packages"

    if command -v fc-cache >/dev/null 2>&1; then
        log "Refreshing font cache..."
        sudo fc-cache -f || handle_error "Refreshing font cache"
        fc-cache -f || log "Warning: failed to refresh user font cache"
    fi

    # Microsoft fonts section (user-supplied TrueType/OpenType)
    install_ms_fonts
}

# Install Microsoft fonts (user-supplied TTF/OTF)
install_ms_fonts() {
    log "Installing Microsoft fonts from user-supplied TTF/OTF files..."
    install_user_ms_fonts
}

# Install user-supplied Microsoft fonts from common home directories
install_user_ms_fonts() {
    log "Checking for user-supplied Microsoft fonts in home directory..."
    local dest_dir="$HOME/.local/share/fonts/MSUser"
    mkdir -p "$dest_dir"

    # Candidate folders where the user might drop font files
    shopt -s nullglob
    local candidates=(
        "$HOME/MSFonts"        
        "$HOME/Fonts/MS"       
        "$HOME/Fonts/Microsoft"
        "$HOME/Downloads/MSFonts"
    )
    shopt -u nullglob

    local copied=0
    for dir in "${candidates[@]}"; do
        if [ -d "$dir" ]; then
            log "Scanning $dir for .ttf/.otf files..."
            while IFS= read -r -d '' font_file; do
                cp -f "$font_file" "$dest_dir/" && copied=$((copied+1))
            done < <(find "$dir" -maxdepth 2 -type f \( -iname "*.ttf" -o -iname "*.otf" \) -print0 2>/dev/null)
        fi
    done

    if [ "$copied" -gt 0 ]; then
        log "Installed $copied user-supplied Microsoft font files to $dest_dir"
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -f "$dest_dir" || log "Warning: failed to refresh user font cache for $dest_dir"
        fi
    else
        log "No user-supplied Microsoft fonts found. Place .ttf/.otf files into ~/MSFonts or ~/Fonts/MS and re-run."
    fi
}

# Function to configure KDE Plasma desktop
configure_kde_desktop() {
    log "Configuring KDE Plasma desktop..."

    if ! rpm -q plasma-desktop >/dev/null 2>&1; then
        log "KDE Plasma not detected (plasma-desktop missing); skipping KDE configuration."
        return
    fi

    sudo dnf install -y papirus-icon-theme breeze-gtk kvantum kvantum-manager yakuake plasma-systemmonitor kde-gtk-config plasma-discover || handle_error "Installing KDE customization packages"

    if systemctl list-unit-files | grep -q '^sddm.service'; then
        sudo systemctl enable sddm || handle_error "Enabling SDDM display manager"
    fi

    local kvantum_theme_dir="$HOME/.config/Kvantum"
    local kvantum_theme_name="Win7Glass"
    local kvantum_theme_path="$kvantum_theme_dir/$kvantum_theme_name"

    if command -v kvantummanager >/dev/null 2>&1; then
        log "Installing Kvantum glass theme..."
        mkdir -p "$kvantum_theme_path"

        cat <<'EOF' > "$kvantum_theme_path/$kvantum_theme_name.kvconfig"
[General]
author=wolf-howl
comment=A lightweight Windows 7 style glass Kvantum theme
transparency=true
blur=true
menu_opacity=0.7
window_opacity=0.75
tooltip_opacity=0.85
inactive_opacity=0.65
active_opacity=0.85
decoration_opacity=0.78
contrast=1.0
use_system_icons=true
rounded_corners=true
roundness=6.0

[Colors]
window.background=#1A1A1A
window.foreground=#FFFFFF
inactive.background=#1A1A1A
inactive.foreground=#C7C7C7
highlight.background=#3A7ED9
highlight.foreground=#FFFFFF
midlight.background=#FFFFFF
mid.background=#202020
text.hilight=#FFFFFF

[Effects]
shadow_size=30
shadow_color=#000000
shadow_opacity=0.55
glow_size=8
glow_color=#00FF7F
glow_opacity=0.65

[Hints]
menu_blur=true
tooltip_blur=true
sidepanel_blur=true
use_precision_tweak=true
EOF

        mkdir -p "$kvantum_theme_path/palettes"
        cat <<'EOF' > "$kvantum_theme_path/palettes/$kvantum_theme_name.colors"
[Colors:View]
BackgroundNormal=26,26,26
ForegroundNormal=255,255,255

[Colors:Window]
BackgroundNormal=26,26,26
ForegroundNormal=255,255,255

[Colors:Button]
BackgroundNormal=0,255,127
ForegroundNormal=255,255,255

[Colors:Selection]
BackgroundNormal=0,255,127
ForegroundNormal=255,255,255

[Colors:Tooltip]
BackgroundNormal=20,20,20
ForegroundNormal=240,240,240

[Colors:Complementary]
BackgroundNormal=20,20,20
ForegroundNormal=255,255,255
EOF

        log "Activating Kvantum glass theme..."
        kvantummanager --set "$kvantum_theme_name" || log "Warning: Unable to apply Kvantum theme automatically"

        if command -v kwriteconfig5 >/dev/null 2>&1; then
            kwriteconfig5 --file kdeglobals --group KDE --key widgetStyle "kvantum"
            kwriteconfig5 --file kdeglobals --group General --key ColorScheme "$kvantum_theme_name"
        fi

        if command -v qdbus >/dev/null 2>&1; then
            qdbus org.kde.KWin /Compositor org.kde.kwin.Compositing.reinitialize &>/dev/null || true
        fi
    else
        log "kvantummanager not available; skipping Kvantum theme application."
    fi

    if command -v kwriteconfig5 >/dev/null 2>&1; then
        log "Applying Breeze Dark look-and-feel and Papirus icons..."
        kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
        kwriteconfig5 --file kdeglobals --group General --key ColorScheme BreezeDark
        kwriteconfig5 --file kdeglobals --group Icons --key Theme Papirus-Dark
        kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme Breeze_Snow
    kwriteconfig5 --file kdeglobals --group General --key font "MS Sans Serif,10,-1,5,50,0,0,0,0,0"
        kwriteconfig5 --file kdeglobals --group General --key fixed "JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
    kwriteconfig5 --file kdeglobals --group General --key smallFont "MS Sans Serif,9,-1,5,50,0,0,0,0,0"
    kwriteconfig5 --file kdeglobals --group WM --key activeFont "MS Sans Serif,10,-1,5,75,0,0,0,0,0"
    else
        log "kwriteconfig5 not found; skipping KDE configuration file tweaks."
    fi

    log "Aligning GTK themes with KDE..."
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    cat <<'EOF' > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=MS Sans Serif 10
gtk-cursor-theme-name=Breeze_Snow
EOF
    cp "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

    log "KDE Plasma configuration applied."
}

# Function to install gaming-focused tools and dependencies
install_gaming_tools() {
    log "Installing gaming performance tools and dependencies..."
    sudo dnf install -y gamemode gamemode-devel gamescope mangohud goverlay protontricks wine winetricks steam-devices vulkan-loader vulkan-loader.i686 mesa-vulkan-drivers mesa-vulkan-drivers.i686 || handle_error "Installing gaming performance tools"

    log "Enabling gamemoded service..."
    sudo systemctl enable --now gamemoded || handle_error "Enabling gamemoded service"

    log "Installing Flatpak gaming utilities (Heroic, Bottles, ProtonUp-Qt)..."
    flatpak install -y --noninteractive flathub com.heroicgameslauncher.hgl com.usebottles.bottles net.davidotek.pupgui2 || handle_error "Installing Flatpak gaming utilities"
}

# Function to install 32-bit libraries
install_32bit_libraries() {
    log "Installing 32-bit libraries..."
    sudo dnf install -y glibc.i686 libstdc++.i686 zlib.i686 libX11.i686 libXext.i686 || handle_error "Installing 32-bit libraries"
}

# Function to install specific RPM packages
install_rpm_packages() {
    log "Installing specific RPM packages..."
    log "Configuring 1Password repository..."
    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc || handle_error "Importing 1Password GPG key"

    sudo tee /etc/yum.repos.d/1password.repo >/dev/null <<'EOF' || handle_error "Creating 1Password repository"
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
repo_gpgcheck=1
repo_gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF

    log "Installing 1Password..."
    sudo dnf install -y 1password || handle_error "Installing 1Password"

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
install_additional_apps
install_fonts_and_emoji
configure_kde_desktop
install_gaming_tools
install_32bit_libraries
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
