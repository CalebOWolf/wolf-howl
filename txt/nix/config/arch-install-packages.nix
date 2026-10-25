{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- System & Utilities ---
    curl                 # Command-line downloader
    git                  # Version control
    net-tools            # Networking utilities (ifconfig, netstat, etc.)
    nano                 # Command-line text editor
    unzip                # Archive extraction
    p7zip                # 7z archive support

    # --- Media & GStreamer ---
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    libxcrypt-legacy     # Legacy binary support

    # --- Audio & Video ---
    pavucontrol          # PulseAudio volume control
    handbrake            # Video transcoding
    libGLU               # OpenGL utilities

    # --- Productivity & Tools ---
    keepassxc            # Password manager
    libreoffice-fresh    # Office suite
    qbittorrent          # Torrent client

    # --- Gaming & System Performance ---
    lutris               # Game launcher
    resources            # Modern system monitor
    mission-center       # Windows-style system monitor

    # --- Desktop Applications ---
    blanket              # Ambient noise player
    cpu-x                # Hardware info tool
    gpu-viewer           # GPU diagnostics
    ktailctl             # Tailscale GUI
    shortwave            # Internet radio
    spotify              # Music streaming
    gnome-weather        # Weather app

    # --- Graphics & UI ---
    gdk-pixbuf           # Image handling
    less                 # Terminal pager
  ];

  fonts.packages = with pkgs; [
    corefonts            # Microsoft Core Fonts
    font-awesome         # Icon fonts
    nerd-fonts.arimo     # Arimo Nerd Font
  ];
}
