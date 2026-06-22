{ pkgs, ... }:

{
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
    tailscale
    xdg-utils
    xdg-user-dirs
    krita
    gimp
    gnome-disk-utility
    obs-studio
    bazaar
    yt-dlp
    hyfetch
    impression
    antigravity
    bleachbit
    blender
    ghostty
  ];

  # Install firefox, thunderbird, and partition manager.
  programs.firefox.enable = true;
  programs.thunderbird.enable = true;
  programs.partition-manager.enable = true;
}
