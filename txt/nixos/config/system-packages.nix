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
    wget
    curl
    btop
    vscode

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
    pciutils
    ethtool
    bleachbit

    # Filesystem tools
    dosfstools
    exfatprogs
    ntfs3g

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
}
