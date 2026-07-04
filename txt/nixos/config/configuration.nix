# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      
      # System configuration modules
      ./networking.nix               # Network settings and connectivity
      ./kernel.nix                   # Kernel configuration
      ./network.nix                  # Network and performance tuning (merged from ethernet.nix and performance.nix)
      ./amd.nix                      # AMD-specific settings
      ./nix-settings.nix             # Nix package manager settings
      
      # Desktop environment and UI
      ./desktop.nix                  # Desktop environment base
      ./kde-packages.nix             # KDE Plasma packages
      ./fonts.nix                    # Font configuration
      
      # Application modules
      ./system-packages.nix          # System-wide packages
      ./extraction.nix               # Archive extraction tools
      ./flatpak.nix                  # Flatpak support
      ./syncthing.nix                # File synchronization
      
      # Gaming and media
      ./gaming.nix                   # Gaming support
      ./steam-timeout-inhibit.nix    # Steam idle timeout prevention
      ./sunshine.nix                 # Sunshine streaming server
      
      # Hardware-specific
      ./samsung.nix                  # Samsung device support
    ];

  # ============================================================================
  # Bootloader Configuration
  # ============================================================================
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;
  
  # Additional boot utilities
  boot.loader.systemd-boot.netbootxyz.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  # ============================================================================
  # Locale and Internationalization
  # ============================================================================
  
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

  # ============================================================================
  # Console Configuration
  # ============================================================================
  
  console.keyMap = "us";

  # ============================================================================
  # Nixpkgs Configuration
  # ============================================================================
  
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };

  # ============================================================================
  # Security Hardening
  # ============================================================================
  
  security.sudo = {
    wheelNeedsPassword = true;
    execWheelOnly = true;
  };
  
  # Kernel security hardening
  security.protectKernelImage = true;
  security.lockKernelModules = true;
  security.apparmor.enable = true;

  # ============================================================================
  # User Accounts
  # ============================================================================
  
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users."calebowolf" = {
    isNormalUser = true;
    description = "Caleb Mignano";
    extraGroups = [
      "networkmanager"  # Network management
      "wheel"           # Sudo access
      "audio"           # Audio device access
      "video"           # Video/GPU access
      "input"           # Input device access
      "uucp"            # Serial port access (if needed)
    ];
    shell = pkgs.fish;
  };

  # ============================================================================
  # System State Version
  # ============================================================================
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
