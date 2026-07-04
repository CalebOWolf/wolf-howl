{ pkgs, ... }:

{
  # Enable the Syncthing service, running in the background and starting on boot.
  services.syncthing = {
    enable = true;
    user = "calebowolf";
    dataDir = "/home/calebowolf/Sync";
    configDir = "/home/calebowolf/.config/syncthing";
    openDefaultPorts = true;
  };
}
