{ pkgs, ... }:

{
  # KDE Plasma 6 on Wayland (X11 disabled)
  services.xserver.enable = false;
  services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };

  # Printing
  services.printing = {
  enable = true;
  drivers = [ pkgs.gutenprint ];  # or other drivers you need
  };

  # Wayland and portal behavior for Electron/Chromium OAuth callbacks.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GTK_USE_PORTAL = "1";
  };

  # Secret service backend used by many desktop apps and credential helpers.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services = {
    login.enableGnomeKeyring = true;
    sddm.enableGnomeKeyring = true;
  };

  # Qt/Plasma integration
  qt.enable = true;
  qt.style = "breeze";

  # XDG portals for Wayland and Flatpak integration.
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config = {
      common = {
        default = [ "kde" ];
      };
    };
  };

  # Keep URL handlers explicit so OAuth browser handoff works consistently.
  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
