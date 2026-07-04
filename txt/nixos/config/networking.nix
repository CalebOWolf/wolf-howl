{ pkgs, ... }:

{
  # Hostname configuration
  networking.hostName = "wolfhowlnixos";

  # Networking stack - NetworkManager handles wireless and wired connections
  # networking.wireless.enable is disabled to prevent conflicts with NetworkManager
  networking.networkmanager.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # Check reverse path to prevent spoofing, set to "loose" for Tailscale compatibility
    checkReversePath = "loose";
    # Log dropped reverse path packets for debugging
    logReversePathDrops = true;
    # Trust Tailscale interface
    trustedInterfaces = [ "tailscale0" ];
    # Tailscale WireGuard UDP port
    allowedUDPPorts = [ 41641 ];
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
      # Disable password authentication; use SSH keys only
      PasswordAuthentication = false;
      # Prevent root login via SSH
      PermitRootLogin = "no";
      # Disable X11 forwarding unless explicitly needed
      X11Forwarding = false;
    };
  };

  # Tailscale VPN service
  services.tailscale = {
    enable = true;
    # Use both subnet routes and exit node features
    useRoutingFeatures = "both";
  };
}
