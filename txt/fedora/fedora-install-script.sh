#!/bin/bash
# Fedora Installation Script for my system of the hardware being an AMD Ryzen 5700X and Nvidia 5060 this will setup the CPU and GPU drivers and optimizations for the system to run the way id like it to run. 
# Additionally it will install a variety of applications via RPM and Flatpak to get a good base system setup for general use, gaming, and content creation. 
# If this script is run on a fresh Fedora install it will also update the system and install essential tools. such as rpm fusion and development tools. Among that my script will also install 32-bit libraries for compatibility with games and other applications that may require them.
# Finally the script will reboot the system to ensure all changes take effect.
# I ASSUME THIS SCRIPT IS BEING RUN AS USER WITH SUDO PRIVILEGES. I PRESSUME YOU KNOW WHAT YOUR DOING IF YOU RUN THIS SCRIPT. ALONG EWITH THAT I TAKE NO RESPONSIBILITY FOR ANY DAMAGE OR DATA LOSS THAT MAY OCCUR FROM RUNNING THIS SCRIPT. BACKUP YOUR DATA BEFORE RUNNING THIS SCRIPT.
# Suggestions can be made to improve this script by opening an issue on my GitHub page: CalebOWolf/wolf-howl/fedora-setup-script

# Start of the script
echo "Starting Fedora installation and setup script..."

# Update the system
echo "Updating the system..."
sudo dnf update -y
sudo dnf upgrade -y
sudo dnf install -y dnf-plugins-core kernel-devel kernel-headers

# Install essential tools
echo "Installing essential tools..."
sudo dnf install -y wget curl git vim gcc make dkms git vim vi bat fzf tmux zsh sed xargs nnn htop nmtui ncdu cmus mc playerctl notify-send xdotool youtube-dl

# Update after enabling RPM Fusion
echo "Updating The System..."
sudo dnf update -y

# Install AMD Radeon Drivers
echo "Swapping Mesa Drivers"
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686

# Install additional multimedia codecs (RPM Fusion)
echo "Installing multimedia codecs..."
sudo dnf install -y gstreamer1-plugins-base gstreamer1-plugins-good-extras gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free-extras gstreamer1-plugins-ugly gstreamer1-plugins-ugly-free gstreamer1-libav lame ffmpeg libdvdcss libdvdread handbrake vlc obs-studio simplescreenrecorder

# Install tools for AMD Ryzen optimization
echo "Installing tools for AMD Ryzen optimization..."
sudo dnf install -y amd-ucode
sudo dnf install -y tuned cpupower
echo "Enabling and starting tuned service..."
sudo systemctl enable tuned
sudo systemctl start tuned
echo "Setting tuned profile to 'latency-performance'..."
sudo tuned-adm profile latency-performance

# Install temperature monitoring tools
echo "Installing temperature monitoring tools (lm_sensors)..."
sudo dnf install -y lm_sensors
echo "Detecting sensors (you may need to run 'sudo sensors-detect' interactively after install)..."
# Optionally, uncomment the next line to run sensors-detect automatically (may require user input):
# sudo sensors-detect --auto

# Set CPU frequency scaling for Ryzen 5700X
echo "Setting CPU frequency scaling for Ryzen 5700X..."
# Set governor to performance and min/max frequency to safe values (adjust as needed)
sudo cpupower frequency-set -g performance
# Optionally, set min/max frequency (example: 3.4GHz min, 4.6GHz max for 5700X)
sudo cpupower frequency-set -d 3.4GHz -u 4.6GHz
echo "CPU frequency scaling set. You can check with: cpupower frequency-info"

# Install OpenRGB for RGB control
echo "Installing OpenRGB..."
sudo dnf install -y https://openrgb.org/releases/openrgb-0.7-linux-x86_64.rpm
# Note: You may need to adjust the above command based on the actual installation instructions for OpenRGB.

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
sudo dnf install -y openssh curl xorg-x11-font-utils fontconfig libreoffice lutris krita blender pavucontrol-qt bleachbit gparted steam hyfetch gimp obs-studio kdenlive vlc audacity simplescreenrecorder handbrake ffmpeg lm_sensors htop

# Install 32-bit libraries for compatibility
echo "Installing 32-bit libraries for compatibility..."
sudo dnf install -y glibc.i686 libstdc++.i686 zlib.i686 libX11.i686 libXext.i686 libXrender.i686 libXrandr.i686 libXcursor.i686 libXfixes.i686 libXi.i686 libXdamage.i686 libXcomposite.i686 libXtst.i686 libSM.i686 libICE.i686 libGL.i686 libGLU.i686 mesa-libGL.i686 mesa-libGLU.i686 libdrm.i686 libdbus-glib-1.i686 alsa-lib.i686 pulseaudio-libs.i686 cups-libs.i686 libvdpau.i686 libva.i686 freetype.i686 fontconfig.i686 freetype-freeworld.i686 fontconfig-freeworld.i686 libpng.i686 libjpeg-turbo.i686

# Install Applications via RPM packages
# Install 1Password from their official website
echo "Installing 1Password..."
wget https://downloads.1password.com/linux/rpm/stable/x86_64/1password-latest.rpm -O /tmp/1password.rpm
sudo dnf install -y /tmp/1password.rpm
rm -f /tmp/1password.rpm

# Install Google Chrome
echo "Downloading Google Chrome RPM package..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/google-chrome.rpm
echo "Installing Google Chrome..."
sudo dnf install -y /tmp/google-chrome.rpm
rm -f /tmp/google-chrome.rpm

# FS Voice
echo "Installing FS Voice..."
sudo dnf install -y libstdc++.i686 libidn1.34.i686 libidn2.i686 gstreamer1-plugins-bad-free.i686 gstreamer1-plugins-bad-free-extras.i686 gstreamer1-plugins-base.i686 gstreamer1-plugins-good.i686 gstreamer1-plugins-good-extras.i686 gstreamer1-plugins-ugly.i686 gstreamer1-plugins-ugly-free.i686 libuuid.i686 libzip.i686 alsa-plugins-pulseaudio.i686 libidn1.34.i686

# Install Discord from their official website
#echo "Installing Discord..."
#wget https://discord.com/api/download?platform=linux&format=rpm -O /tmp/discord.rpm
#sudo dnf install -y /tmp/discord.rpm
#rm -f /tmp/discord.rpm

# Install Visual Studio Code
echo "Installing VSCode..."
wget https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64 -O /tmp/vscode.rpm
sudo dnf install -y /tmp/vscode.rpm
rm -f /tmp/vscode.rpm

# Install Flatpak applications
echo "Installing Flatpak applications..."
flatpak install -y flathub com.discordapp.Discord org.telegram.desktop org.firestormviewer.FirestormViewer org.prismlauncher.PrismLauncher io.github.shiftey.Desktop io.mgba.mGBA sh.ppy.osu org.ppsspp.PPSSPP com.vysp3r.ProtonPlus net.davidotek.pupgui2 net.rpcs3.RPCS3 app.twintaillauncher.ttl com.github.joseexposito.touche org.nickvision.tubeconverter org.qbittorrent.qBittorrent org.remmina.Remmina com.transmissionbt.Transmission com.github.unrud.VideoDownloader io.github.wivrn.wivrn org.audacityteam.Audacity com.rafaelmardojai.Blanket io.github.celluloid_player.Celluloid com.obsproject.Studio fr.handbrake.ghb org.kde.kdenlive de.haeckerfelix.Shortwave io.github.arunsivaramanneo.GPUViewer io.gitlab.adhami3310.Impression io.github.ilya_zlobintsev.LACT com.usebottles.bottles com.github.tchx84.Flatseal it.mijorus.gearlever org.keepassxc.KeePassXC org.localsend.localsend_app org.x.Warpinator io.github.fastrizwaan.WineZGUI

echo "Performing final system update and cleanup..."
sudo dnf update -y
sudo dnf autoremove -y
sudo flatpak update -y

# Reboot the system
echo "Fedora installation and setup script completed."
echo "Installation complete. Rebooting the system..."
sleep 5
sudo reboot

# End of the script
Copyright © 2025 CalebOWolf/Caleb Mignon. All rights reserved.
