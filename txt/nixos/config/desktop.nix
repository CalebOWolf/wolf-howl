{ pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = false;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Configure console keymap to use xkb config
  console.useXkbConfig = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Wayland scaling for Electron apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # XDG Desktop integration
  xdg = {
    autostart.enable = true;
    sounds.enable = true;
    portal.enable = true;
    icons.enable = true;
    menus.enable = true;
    mime.enable = true;
  };
}
