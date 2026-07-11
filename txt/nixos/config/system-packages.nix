{ pkgs, ... }:

{
  imports = [
    ./arch-install-packages.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Development & CLI tools
    vim
    git
    git-credential-manager
    gh
    ripgrep
    fd
    jq
    tree
    bat
    wget
    curl
    btop
    vscode
    nixd
    alejandra

    # Hardware / diagnostics
    lshw
    usbutils
    smartmontools
    lm_sensors

    # Multimedia
    vlc
    obs-studio
    yt-dlp
    krita
    gimp
    blender

    # System utilities
    xdg-utils
    xdg-user-dirs
    gnome-disk-utility
    seahorse
    playerctl
    networkmanagerapplet
    kdeconnect
    pciutils
    ethtool
    bleachbit

    # Filesystem tools
    dosfstools
    ntfs3g
    exfat
    exfatprogs

    # Applications
    discord
    telegram-desktop
    ghostty  # GPU-accelerated terminal emulator
    bazaar

    # System information
    hyfetch
    fastfetch
    impression
  ];

  # Enable programs with their own modules
  programs.firefox.enable = true;
  programs.thunderbird.enable = true;
  programs.partition-manager.enable = true;
  programs.fish.enable = true;

  programs.git = {
    enable = true;
    config = {
      credential = {
        helper = "manager";
        useHttpPath = true;
      };
    };
  };
}
