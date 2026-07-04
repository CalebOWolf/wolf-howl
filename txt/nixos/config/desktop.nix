{ pkgs, ... }:

{
  # KDE Plasma 6 on Wayland (X11 disabled)
  services.xserver.enable = false;
  services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # Wayland optimization for Electron
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Qt/Plasma integration
  qt.enable = true;
  qt.style = "breeze";

  # Fonts
  fonts.fontconfig.enable = true;
}
