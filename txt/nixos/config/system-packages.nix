{ pkgs, ... }:

{
  imports = [
    ./arch-install-packages.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    vlc
    btop
    discord
    telegram-desktop
    xdg-utils
    xdg-user-dirs
    krita
    gimp
    gnome-disk-utility
    obs-studio
    bazaar
    yt-dlp
    hyfetch
    fastfetch
    impression
    antigravity
    bleachbit
    blender
    ghostty
    pciutils
    ethtool
    ghostty              # GPU-accelerated terminal emulator
  ];

  # Install firefox, thunderbird, partition manager, and enable fish shell.
  programs.firefox.enable = true;
  programs.thunderbird.enable = true;
  programs.partition-manager.enable = true;
  programs.fish.enable = true;
}
