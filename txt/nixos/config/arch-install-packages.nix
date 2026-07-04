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
    libxcrypt-legacy     # For running some legacy binaries / voice clients

    # --- Productivity & Tools ---
    lutris               # Game manager/launcher
    keepassxc            # Password manager
    libreoffice-fresh    # Office suite
    handbrake            # Video transcoder
    qbittorrent          # Torrent client

    # --- Flatpak equivalents packaged in NixOS ---
    blanket              # Ambient noise player
    cpu-x                # System profiling and hardware info (CPU-Z clone)
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
}
