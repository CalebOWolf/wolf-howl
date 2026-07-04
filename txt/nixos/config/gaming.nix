{ pkgs, ... }:

{
  # Hardware acceleration for gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for many Steam games
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
    ];
    extraPackages32 = with pkgs; [
      vulkan-loader
    ];
  };

  # Steam configuration
  programs.steam = {
    enable = true;
    extest.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Steam hardware support & performance optimization
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;

  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Steam & Proton tools
    steam
    steamcmd
    protonplus
    proton-vpn
    protonup-qt
    protontricks
    
    # Game launchers
    osu-lazer-bin
    prismlauncher
  ];
}
