# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "wolfhowlnixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;
  # Hyprland
  programs.hyprland.enable = true;
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Nix LD
  # programs.nix-ld.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.calebmignano = {
    isNormalUser = true;
    description = "Caleb Mignano";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    packages = with pkgs; [
      kdePackages.kate
      thunderbird
      discord
      telegram-desktop
      blender
      unityhub
      krita
      prismlauncher
      _1password-gui
      _1password-cli
      vscode
      vlc
      docker
      github-desktop
      libreoffice
      roboto
      roboto-serif
      google-chrome
      obs-studio
      qbittorrent
      gamescope
      gamemode
      lutris
      git
      kitty
      vim
      pipewire
      pwvucontrol
      sonusmix
      helvum
      wayfarer
      pipecontrol
      pa-notify
      obs-studio-plugins.obs-pipewire-audio-capture
      wayland-pipewire-idle-inhibit
      xwayland
      xdg-user-dirs
      xfce.thunar
      xfce.thunar-volman
      xfce.thunar-dropbox-plugin
      xfce.thunar-archive-plugin
      xfce.thunar-media-tags-plugin
      udiskie
      kde-gtk-config
      font-awesome
      noto-fonts
      noto-fonts-color-emoji
      bluez
      bluez-alsa
      bluez-tools
      blueberry
      protonup-qt
      wofi
      swaynotificationcenter
      hyprpolkitagent
      xdg-desktop-portal-hyprland
      eww
      waybar
      hyprpaper
      hyprwall
      vesktop
      hyprpicker
      clipse
      hypridle
      hyprlock
      hyprland-protocols
      hyprlandPlugins.hyprtrails
      hyprlandPlugins.hyprfocus
      hyprlandPlugins.hyprbars
      hyprlandPlugins.hypr-dynamic-cursors
      hyprcursor
      hyprdim
      hyprshot
      hyprlang
      hyprutils
    ];
  };

  # Install firefox, Steam
  programs.firefox.enable = true;
  programs.steam.enable = true;

  # Flathub
  services.flatpak.enable = true;
  # Then do-
  # sudo nixos-rebuild switch
  # flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
