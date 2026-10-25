{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
    ];
    extraPackages32 = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    extest.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;

    # Improves compatibility for some Windows games.
    extraCompatPackages = with pkgs; [ proton-ge-bin ];

    # Uncomment if you host Steam dedicated servers.
    # dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    steamcmd
    protonup-qt
    protontricks

    # Optional launchers.
    # heroic
    # lutris
    # bottles
    
    osu-lazer-bin
    prismlauncher
    
    # Optional: performance monitoring
    mangohud
  ];
}
