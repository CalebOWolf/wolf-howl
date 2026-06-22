{ pkgs, ... }:

{
  # Enable hardware accelerated graphics drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for many Steam games
  };

  # Steam configuration & firewall rules
  programs.steam = {
    enable = true;
    extest.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;

  # Gaming-related system packages
  environment.systemPackages = with pkgs; [
    steam
    steamcmd
    protonplus
    proton-vpn
    protonup-qt
    protontricks
    osu-lazer-bin
    prismlauncher
  ];
}
