{ pkgs, ... }:

{
  # Hostname configuration
  networking.hostName = "wolfhowlnixos";
  # Domain name (adjust as needed)
  # networking.domain = "example.com";

  # Networking stack - NetworkManager handles wireless and wired connections
  networking.networkmanager.enable = true;
  # Use NetworkManager for DNS management instead of systemd-resolved
  networking.dhcpcd.enable = false;

  # IPv6 configuration
  networking.enableIPv6 = true;

  # DNS configuration - using Cloudflare as default (change as needed)
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  # Use resolver options (e.g., EDNS0 support for larger DNS queries)
  networking.resolvconf.extraOptions = [ "edns0" ];

  # Firewall configuration with hardening
  networking.firewall = {
    enable = true;
    # SSH is handled by the SSH service below
    allowedTCPPorts = [ 22 ];
    # Tailscale WireGuard UDP port (see services.tailscale below)
    allowedUDPPorts = [ 41641 ];
    # Check reverse path to prevent spoofing; set to "loose" for Tailscale compatibility
    checkReversePath = "loose";
    # Log dropped reverse path packets for debugging
    logReversePathDrops = true;
    # Trust Tailscale interface to prevent firewall blocking
    trustedInterfaces = [ "tailscale0" ];
    # Reject connections instead of dropping them (helps with debugging)
    rejectPackets = false;
    # Additional firewall rules can be added here if needed
    # extraCommands = ''
    #   # Example: Allow traffic from specific subnet
    #   # iptables -A nixos-fw -s 192.168.1.0/24 -j ACCEPT
    # '';
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
      # Disable X11 forwarding for security (enable if needed)
      X11Forwarding = false;
      # Limit authentication attempts to prevent brute force attacks
      MaxAuthTries = 3;
      # Close connection after 2 minutes of inactivity
      ClientAliveInterval = 120;
      ClientAliveCountMax = 1;
      # Only allow public key authentication
      PubkeyAuthentication = true;
      # Use stronger key exchange algorithms (optional, depends on NixOS version)
      # KexAlgorithms = "curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
    };
    # Optional: restrict SSH access to specific users
    # allowUsers = [ "user1" "user2" ];
  };

  # Tailscale VPN service for secure remote access and subnet routing
  services.tailscale = {
    enable = true;
    # Use both subnet routes and exit node features
    useRoutingFeatures = "both";
    # Optional: customize Tailscale behavior on startup
    # extraUpFlags = [
    #   "--accept-dns=false"  # Set to true if you want Tailscale to manage DNS
    #   "--advertise-routes=192.168.1.0/24"  # Advertise local subnet if acting as exit node
    # ];
  };
}
