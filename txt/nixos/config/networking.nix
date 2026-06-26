{ pkgs, ... }:

{
  networking.hostName = "wolfhowlnixos"; # Define your hostname.
  # networking.wireless.enable = false;  # Disabled to prevent conflict with NetworkManager
  
  # Enable networking
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable Tailscale service and configure firewall.
  services.tailscale.enable = true;
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ 41641 ];
}
