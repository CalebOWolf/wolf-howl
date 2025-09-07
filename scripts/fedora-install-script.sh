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
sudo dnf install -y dnf-plugins-core 
sudo dnf install -y kernel-devel 
sudo dnf install -y kernel-headers

# Install essential tools
echo "Installing essential tools..."
sudo dnf install -y wget
sudo dnf install -y curl
sudo dnf install -y git
sudo dnf install -y vim
sudo dnf install -y gcc
sudo dnf install -y make
sudo dnf install -y dkms

# Update after enabling RPM Fusion
echo "Updating The System..."
sudo dnf update -y

# Install Nvidia drivers
echo "Installing Nvidia drivers..."
sudo dnf install -y akmod-nvidia
sudo dnf install -y xorg-x11-drv-nvidia-cuda
sudo dnf install -y xorg-x11-drv-nvidia
sudo dnf install -y xorg-x11-drv-nvidia-libs
sudo dnf install -y nvidia-settings
sudo dnf install -y libvdpau
sudo dnf install -y libva-vdpau-driver
sudo dnf install -y vdpau
sudo dnf install -y ffmpeg
sudo dnf install -y vulkan vulkan-tools
sudo dnf install -y vulkan-validation-layers
sudo dnf install -y xorg-x11-drv-nvidia-power

# Ensure the Nvidia kernel module is built
echo "Building Nvidia kernel module..."
sudo akmods --force
sudo dracut --force

# Install additional multimedia codecs (optional)
echo "Installing multimedia codecs..."
sudo dnf install -y gstreamer1-plugins-base
sudo dnf install -y gstreamer1-plugins-good-extras
sudo dnf install -y gstreamer1-plugins-good
sudo dnf install -y gstreamer1-plugins-bad-free
sudo dnf install -y gstreamer1-plugins-bad-free-extras
sudo dnf install -y gstreamer1-plugins-ugly
sudo dnf install -y gstreamer1-plugins-ugly-free
sudo dnf install -y gstreamer1-libav
sudo dnf install -y lame
sudo dnf install -y ffmpeg
sudo dnf install -y x264
sudo dnf install -y x265
sudo dnf install -y libdvdcss
sudo dnf install -y libdvdread
sudo dnf install -y libdvdnav
sudo dnf install -y libavcodec
sudo dnf install -y handbrake
sudo dnf install -y vlc
sudo dnf install -y obs-studio
sudo dnf install -y simplescreenrecorder

# Install tools for AMD Ryzen optimization
echo "Installing tools for AMD Ryzen optimization..."
sudo dnf install -y cpupower

# Enable and configure CPU performance tuning
echo "Configuring CPU performance tuning..."
sudo systemctl enable --now tuned
sudo tuned-adm profile balanced
sudo cpupower frequency-set -g performance

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
sudo dnf install -y openssh
sudo dnf install -y curl 
sudo dnf install -y xorg-x11-font-utils 
sudo dnf install -y fontconfig 
sudo dnf install -y libreoffice 
sudo dnf install -y lutris 
sudo dnf install -y krita 
sudo dnf install -y blender 
sudo dnf install -y spotify-client 
sudo dnf install -y pavucontrol-qt 
sudo dnf install -y bleachbit 
sudo dnf install -y gparted

# Install 1Password from their official website
echo "Installing 1Password..."
wget https://downloads.1password.com/linux/rpm/stable/1password-latest.rpm -O /tmp/1password.rpm
sudo dnf install -y /tmp/1password.rpm
rm -f /tmp/1password.rpm

# Install Google Chrome
echo "Downloading Google Chrome RPM package..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/google-chrome.rpm
echo "Installing Google Chrome..."
sudo dnf install -y /tmp/google-chrome.rpm
rm -f /tmp/google-chrome.rpm

# Install Visual Studio Code
echo "Installing VSCode..."
wget https://update.code.visualstudio.com/latest/linux-rpm-x64/stable -0 /tmp/vscode.rpm
sudo dnf install -y /tmp/vscode.rpm
rm -f /tmp/vscode.rpm

# Install Flatpak applications
echo "Installing Flatpak applications..."
flatpak install -y flathub com.discordapp.Discord org.telegram.desktop org.firestormviewer.FirestormViewer net.prismlauncher.PrismLauncher com.github.GitHubDesktop io.mgba.mGBA sh.ppy.osu org.ppsspp.PPSSPP com.github.Matoking.protonplus net.davidotek.pupgui2 net.rpcs3.RPCS3 com.github.johnfactotum.TwinTail com.github.joseexposito.twin org.winehq.WineZGUI com.github.rafostar.Parabolic org.qbittorrent.qBittorrent org.remmina.Remmina com.transmissionbt.Transmission com.github.unrud.VideoDownloader com.github.wivrn.WivrnServer org.audacityteam.Audacity com.rafaelmardojai.Blanket io.github.celluloid_player.Celluloid com.obsproject.Studio fr.handbrake.ghb org.kde.kdenlive de.haeckerfelix.Shortwave com.github.wwmm.gpuviewer com.github.impressionapp.Impression com.github.lact.MissionControl com.usebottles.bottles com.github.tchx84.Flatseal com.github.gearlever.GearLever org.keepassxc.KeePassXC org.localsend.localsend com.linuxmint.Warpinator

# Final system update and cleanup
echo "Performing final system update and cleanup..."
sudo dnf update -y
sudo dnf autoremove -y

# Reboot the system
echo "Installation complete. Rebooting the system..."
sleep 5
sudo reboot
