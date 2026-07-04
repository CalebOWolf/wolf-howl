{ pkgs, ... }:

{
  # Hostname configuration
  networking.hostName = "wolfhowlnixos";

  # Networking stack - NetworkManager handles wireless and wired connections
  networking.networkmanager.enable = true;

  # Firewall configuration with hardening
  networking.firewall = {
    enable = true;
    # SSH is handled by the SSH service below
    allowedTCPPorts = [ 22 ];
    # Tailscale WireGuard UDP port (see services.tailscale below)
    allowedUDPPorts = [ 41641 ];
    # Check reverse path to prevent spoofing; set to "loose" for Tailscale compatibility
    checkReversePath = "loose";
    logReversePathDrops = true;
    # Trust Tailscale interface to prevent firewall blocking
    trustedInterfaces = [ "tailscale0" ];
  };

  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # SSH configuration with security hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
      # Limit authentication attempts to prevent brute force
      MaxAuthTries = 3;
      # Close connection after 2 minutes of inactivity
      ClientAliveInterval = 120;
      ClientAliveCountMax = 1;
    };
  };

  # Tailscale VPN service for secure remote access
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    # Optional: customize Tailscale behavior
    # extraUpFlags = [ "--accept-dns=false" ];
  };
}
