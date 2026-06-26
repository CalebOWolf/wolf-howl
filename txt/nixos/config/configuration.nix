# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./networking.nix
      ./desktop.nix
      ./system-packages.nix
      ./kde-packages.nix
      ./extraction.nix
      ./flatpak.nix
      ./gaming.nix
      ./nix-settings.nix
      ./fonts.nix
      ./amd.nix
      ./ethernet.nix
      ./samsung.nix
      ./kernel.nix
      ./home-manager.nix
      ./performance.nix
      ./secrets.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;
  boot.loader.systemd-boot.netbootxyz.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  # Mount /tmp in RAM for performance and SSD longevity
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Limit systemd journal logs to prevent disk bloat
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    SystemMaxFileSize=100M
  '';

  # Enable systemd-resolved for local DNS caching and security
  services.resolved = {
    enable = true;
    dnssec = "true";
    dnsovertls = "true";
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1#cloudflare-dns.com"
      "1.0.0.1#cloudflare-dns.com"
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."calebowolf" = {
    isNormalUser = true;
    description = "Caleb Mignano";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
