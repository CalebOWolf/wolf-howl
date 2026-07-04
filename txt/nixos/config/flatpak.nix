{ config, pkgs, lib, ... }:

let
  flatpaks = [
    "org.firestormviewer.FirestormViewer"
    "io.github.shonubot.Spruce"
    "com.github.tchx84.Flatseal"
  ];
in
{
  services.flatpak.enable = true;

  # systemd service to manage Flatpak installations
  systemd.services.flatpak-managed = {
    description = "Manage Flatpak applications";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    path = [ pkgs.flatpak ];
    
    script = ''
      set -euo pipefail

      # Ensure Flathub repository is added
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

      # Install configured flatpaks
      ${lib.concatMapStringsSep "\n" (app: "flatpak install --assume-yes --noninteractive flathub ${app} || true") flatpaks}

      # Update all installed flatpaks
      flatpak update --assume-yes --noninteractive
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Timer for daily Flatpak updates
  systemd.timers.flatpak-update = {
    description = "Daily Flatpak update timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    # Bind the timer to the service it should trigger
    unitConfig.Unit = "flatpak-managed.service";
  };
}
