#!/bin/bash
# Fedora Installation Script for my system of the hardware being an AMD Ryzen 5700X and Nvidia 5060 this will setup the CPU and GPU drivers and optimizations for the system to run the way id like it to run. 
# Additionally it will install a variety of applications via RPM and Flatpak to get a good base system setup for general use, gaming, and content creation. 
# If this script is run on a fresh Fedora install it will also update the system and install essential tools. such as rpm fusion and development tools. Among that my script will also install 32-bit libraries for compatibility with games and other applications that may require them.
# Finally the script will reboot the system to ensure all changes take effect.
# I ASSUME THIS SCRIPT IS BEING RUN AS USER WITH SUDO PRIVILEGES. I PRESSUME YOU KNOW WHAT YOUR DOING IF YOU RUN THIS SCRIPT. ALONG EWITH THAT I TAKE NO RESPONSIBILITY FOR ANY DAMAGE OR DATA LOSS THAT MAY OCCUR FROM RUNNING THIS SCRIPT. BACKUP YOUR DATA BEFORE RUNNING THIS SCRIPT.
# Suggestions can be made to improve this script by opening an issue on my GitHub page: CalebOWolf/wolf-howl/fedora-setup-script

# Update the system
echo "Updating the system..."
sudo dnf update -y
sudo dnf upgrade -y
sudo dnf install -y dnf-plugins-core kernel-devel kernel-headers

# Install essential tools
echo "Installing essential tools..."
sudo dnf install -y wget curl git vim gcc make dkms

# Update after enabling RPM Fusion
echo "Updating The System..."
sudo dnf update -y

# Install Nvidia drivers
echo "Installing Nvidia drivers..."
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
sudo dnf install -y xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs
sudo dnf install -y nvidia-settings
sudo dnf install -y libvdpau libva-vdpau-driver vdpau
sudo dnf install -y ffmpeg
sudo dnf install -y vulkan vulkan-tools vulkan-validation-layers
sudo dnf install -y xorg-x11-drv-nvidia-power

# Ensure the Nvidia kernel module is built
echo "Building Nvidia kernel module..."
sudo akmods --force
sudo dracut --force

# Install additional multimedia codecs (optional)
echo "Installing multimedia codecs..."
sudo dnf install -y gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free-extras gstreamer1-plugins-ugly gstreamer1-libav lame

# Install tools for AMD Ryzen optimization
echo "Installing tools for AMD Ryzen optimization..."
sudo dnf install -y cpupower

# Enable and configure CPU performance tuning
echo "Configuring CPU performance tuning..."
sudo systemctl enable --now tuned
sudo tuned-adm profile balanced
sudo cpupower frequency-set -g performance

# Install multimedia codecs and tools
echo "Installing multimedia codecs and tools..."
sudo dnf install -y \
    ffmpeg \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-free-extras \
    gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    gstreamer1-plugins-good-extras \
    gstreamer1-plugins-ugly \
    gstreamer1-plugins-ugly-free \
    gstreamer1-libav \
    lame \
    x264 \
    x265 \
    libdvdcss \
    libdvdread \
    libdvdnav \
    libavcodec \
    libavdevice \
    libavfilter \
    libavformat \
    libavutil \
    libswresample \
    libswscale
    vlc \
    mpv \
    audacity \
    obs-studio \
    simplescreenrecorder \
    kdenlive
    handbrake

# Setup Flatpak
echo "Setting up Flatpak..."
sudo dnf install -y flatpak

# Add Flathub repository
echo "Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Update Flatpak
flatpak update -y

# Install additional RPM applications
echo "Installing additional RPM applications..."
sudo dnf install -y \
    openssh \
    curl cabextract xorg-x11-font-utils fontconfig \
    libreoffice \
    lutris \
    code \
    krita \
    blender \
    spotify-client \
    google-chrome-stable \
    pavucontrol-qt \
    bleachbit \
    gparted

# Install 1Password from their official website
echo "Installing 1Password..."
wget https://downloads.1password.com/linux/rpm/stable/1password-latest.rpm -O /tmp/1password.rpm
sudo dnf install -y /tmp/1password.rpm
rm -f /tmp/1password.rpm

# Install Flatpak applications
echo "Installing Flatpak applications..."
flatpak install -y flathub com.discordapp.Discord \
    org.telegram.desktop \
    org.firestormviewer.FirestormViewer \
    net.prismlauncher.PrismLauncher \
    com.github.GitHubDesktop \
    io.mgba.mGBA \
    sh.ppy.osu \
    org.ppsspp.PPSSPP \
    com.github.Matoking.protonplus \
    net.davidotek.pupgui2 \
    net.rpcs3.RPCS3 \
    com.github.johnfactotum.TwinTail \
    com.github.joseexposito.twin \
    org.winehq.WineZGUI \
    com.github.rafostar.Parabolic \
    org.qbittorrent.qBittorrent \
    org.remmina.Remmina \
    com.transmissionbt.Transmission \
    com.github.unrud.VideoDownloader \
    com.github.wivrn.WivrnServer \
    org.audacityteam.Audacity \
    com.rafaelmardojai.Blanket \
    io.github.celluloid_player.Celluloid \
    com.obsproject.Studio \
    fr.handbrake.ghb \
    org.kde.kdenlive \
    de.haeckerfelix.Shortwave \
    com.github.wwmm.gpuviewer \
    com.github.impressionapp.Impression \
    com.github.lact.MissionControl \
    com.usebottles.bottles \
    com.github.tchx84.Flatseal \
    com.github.gearlever.GearLever \
    org.keepassxc.KeePassXC \
    org.localsend.localsend \
    com.linuxmint.Warpinator

# Install 32-bit libraries for compatibility
echo "Installing 32-bit libraries..."
sudo dnf install -y \
    libstdc++.i686 \
    libidn1.34.i686 \
    libidn2.i686 \
    gstreamer1-plugins-bad-free.i686 \
    gstreamer1-plugins-bad-free-extras.i686 \
    gstreamer1-plugins-base.i686 \
    gstreamer1-plugins-good.i686 \
    gstreamer1-plugins-good-extras.i686 \
    gstreamer1-plugins-ugly.i686 \
    gstreamer1-plugins-ugly-free.i686

# Final system update and cleanup
echo "Performing final system update and cleanup..."
sudo dnf update -y
sudo dnf autoremove -y

# Reboot the system
echo "Installation complete. Rebooting the system..."
sudo reboot
