{ pkgs, ... }:

{
  # Open the default RDP port (3389) in the firewall for TCP and UDP connections.
  # This allows RDP clients (on the local network or via Tailscale) to connect to KRDP.
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];

  # Configure environment variables for the KRDP systemd user services.
  # This fixes the common "black screen" or session disconnection issues by:
  # 1. Forcing KPIPEWIRE to use software encoding (libx264) which is much more stable than VA-API.
  # 2. Preventing VA-API / hardware acceleration crashes by pointing to a dummy driver.
  systemd.user.services.app-org.kde.krdpserver = {
    environment = {
      KPIPEWIRE_FORCE_ENCODER = "libx264";
      LIBVA_DRIVER_NAME = "dummy";
      LIBVA_DRIVERS_PATH = "/nonexistent";
    };
  };

  systemd.user.services.plasma-krdp_server = {
    environment = {
      KPIPEWIRE_FORCE_ENCODER = "libx264";
      LIBVA_DRIVER_NAME = "dummy";
      LIBVA_DRIVERS_PATH = "/nonexistent";
    };
  };
}
