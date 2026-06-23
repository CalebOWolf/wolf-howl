{ config, pkgs, lib, ... }:

let
  # Put Flatpak app IDs in this list to have them automatically installed.
  # Example: [ "org.mozilla.firefox" "com.valvesoftware.Steam" ]
  flatpaks = [
    # Add your Flatpak package IDs here:
    "org.firestormviewer.FirestormViewer"
    "io.github.shonubot.Spruce"
    "com.github.tchx84.Flatseal"
  ];
in
{
  # Enable the flatpak service
  services.flatpak.enable = true;

  # systemd service to run flatpak installs and update all flatpaks on system boot/rebuild
  systemd.services.flatpak-managed = {
    description = "Manage and update Flatpaks";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    path = [ pkgs.flatpak ];
    
    script = ''
      # Ensure Flathub repository is added
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

      # Install configured flatpaks if they are not already installed
      ${lib.concatMapStringsSep "\n" (app: "flatpak install -y --noninteractive flathub ${app}") flatpaks}

      # Update all installed flatpaks
      flatpak update -y --noninteractive
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Set up a systemd timer to automatically run flatpak updates daily
  systemd.timers.flatpak-update = {
    description = "Timer to update Flatpaks daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
