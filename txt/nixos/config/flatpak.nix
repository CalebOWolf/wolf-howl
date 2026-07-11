{ config, pkgs, lib, ... }:

let
  flatpaks = [
    "org.firestormviewer.FirestormViewer"
    "io.github.shonubot.Spruce"
    "com.github.tchx84.Flatseal"
  ];
  
  flathubRemote = "https://dl.flathub.org/repo/flathub.flatpakrepo";
in
{
  services.flatpak.enable = true;

  # One-time setup: add Flathub repository
  systemd.services.flatpak-setup = {
    description = "Setup Flatpak Flathub repository";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    path = [ pkgs.flatpak ];
    
    script = ''
      set -euo pipefail
      echo "[flatpak-setup] Adding Flathub repository..." >&2
      flatpak remote-add --system --if-not-exists flathub ${flathubRemote}
      echo "[flatpak-setup] Flathub repository ready" >&2
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Install configured Flatpak applications
  systemd.services.flatpak-install = {
    description = "Install configured Flatpak applications";
    after = [
      "network-online.target"
      "flatpak-setup.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    path = [ pkgs.flatpak pkgs.desktop-file-utils pkgs.gtk3 ];
    
    script = ''
      set -euo pipefail
      echo "[flatpak-install] Installing Flatpak applications..." >&2

      ${lib.concatMapStringsSep "\n" (app: ''
        if flatpak info --system "${app}" >/dev/null 2>&1; then
          echo "[flatpak-install] ${app} already installed" >&2
        else
          echo "[flatpak-install] Installing ${app}..." >&2
          if ! flatpak install --system --assume-yes --noninteractive flathub "${app}"; then
            echo "[flatpak-install] WARNING: Failed to install ${app}" >&2
          fi
        fi
      '') flatpaks}

      # Refresh appstream and desktop metadata so launchers discover apps.
      flatpak update --system --appstream --assume-yes --noninteractive || true
      update-desktop-database /var/lib/flatpak/exports/share/applications || true
      gtk-update-icon-cache -qtf /var/lib/flatpak/exports/share/icons/hicolor || true

      echo "[flatpak-install] Application installation complete" >&2
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Daily Flatpak updates
  systemd.services.flatpak-update = {
    description = "Update all Flatpak applications";
    
    path = [ pkgs.flatpak ];
    
    script = ''
      set -euo pipefail
      echo "[flatpak-update] Starting Flatpak update..." >&2
      flatpak update --assume-yes --noninteractive
      echo "[flatpak-update] Flatpak update complete" >&2
    '';

    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Timer to trigger daily updates
  systemd.timers.flatpak-update = {
    description = "Daily Flatpak update timer";
    wantedBy = [ "timers.target" ];
    
    timerConfig = {
      OnCalendar = "daily";
      OnBootSec = "5min";  # Also run 5 minutes after boot
      Persistent = true;
    };
  };
}
