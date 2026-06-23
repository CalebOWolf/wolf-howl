{ pkgs, ... }:

{
  # Packages that match your Arch Linux setup (from arch-install-script.sh)
  environment.systemPackages = with pkgs; [
    # --- System & Utilities ---
    net-tools            # net-tools (ifconfig, netstat, etc.)
    nano                 # Alternative command line text editor
    pavucontrol          # PulseAudio Volume Control
    libGLU               # GLU utility library (glu)
    gdk-pixbuf           # GDK Pixbuf library (gdk-pixbuf2)
    less                 # Terminal pager (less)

    # --- Media & GStreamer Plugins ---
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    libxcrypt-compat     # For running some legacy binaries / voice clients

    # --- Productivity & Tools ---
    lutris               # Game manager/launcher
    keepassxc            # Password manager
    libreoffice-fresh    # Office suite
    handbrake            # Video transcoder
    qbittorrent          # Torrent client

    # --- Emulators (from Flatpak list) ---
    dolphin-emu          # GameCube/Wii emulator
    mgba                 # Game Boy Advance emulator
    ppsspp               # PSP emulator
    rpcs3                # PS3 emulator
    pcsx2                # PS2 emulator
    retroarch            # Multi-system emulator frontend

    # --- VR Chat & VR Companion Apps ---
    vrcx                 # VRChat companion application

    # --- Flatpak equivalents packaged in NixOS ---
    blanket              # Ambient noise player
    cpu-x                # System profiling and hardware info (CPU-Z clone)
    flatseal             # Flatpak permission manager
    gpu-viewer           # Frontend to glxinfo/vulkaninfo
    ktailctl             # GUI client for Tailscale
    resources            # Modern system monitor
    mission-center       # Windows-style system monitor
    shortwave            # Internet radio player
    spotify              # Proprietary music streaming client
    gnome-weather        # Weather application
  ];

  # --- Fonts ---
  fonts.packages = with pkgs; [
    corefonts            # Microsoft Core Fonts (ttf-ms-fonts)
    font-awesome         # Icon fonts (otf-font-awesome)
    nerd-fonts.arimo     # Arimo Nerd Font (ttf-arimo-nerd)
  ];

  # --- WiVRn (Wireless VR Streaming Service) ---
  services.wivrn = {
    enable = true;
    openFirewall = true; # Open ports in the system firewall automatically
  };
}
