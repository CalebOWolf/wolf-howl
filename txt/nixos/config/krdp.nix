{ pkgs, ... }:

{
  # Enable KDE Plasma desktop (modern alternative to kde5)
  services.xserver.desktopManager.plasma5.enable = true;

  # Open RDP port for KRDP connections
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];

  # Environment variables for KRDP (global)
  environment.variables = {
    KPIPEWIRE_FORCE_ENCODER = "libx264";
    LIBVA_DRIVER_NAME = "dummy";
    LIBVA_DRIVERS_PATH = "/nonexistent";
  };

  # Optional: Enable hardware graphics support if you want real acceleration
  # hardware.opengl.enable = true;
  # hardware.opengl.driSupport = true;

  # Ensure required packages are available
  environment.systemPackages = with pkgs; [
    xrdp
    x264
  ];
}
