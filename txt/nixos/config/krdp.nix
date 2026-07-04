{ pkgs, ... }:

{
  # Open the default RDP port (3389) in the firewall for TCP and UDP connections.
  # This allows RDP clients (on the local network or via Tailscale) to connect to KRDP.
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];

  # Enable KDE KRDP service
  services.xserver.desktopManager.kde5.enable = true;

  # Configure environment variables for the KRDP systemd user services using systemd.user.sessionVariables
  environment.sessionVariables = {
    KPIPEWIRE_FORCE_ENCODER = "libx264";
    LIBVA_DRIVER_NAME = "dummy";
    LIBVA_DRIVERS_PATH = "/nonexistent";
  };

  # Alternatively, if you need to set these per-user, add to your user's home-manager config:
  # (This goes in ~/.config/home-manager/home.nix or similar)
  # systemd.user.services.krdp-setup = {
  #   Unit.Description = "KRDP environment setup";
  #   Install.WantedBy = [ "graphical-session.target" ];
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.bash}/bin/bash -c 'export KPIPEWIRE_FORCE_ENCODER=libx264; export LIBVA_DRIVER_NAME=dummy'";
  #   };
  # };
}
