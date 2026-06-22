{ pkgs, ... }:

{
  # Nix package manager settings
  nix = {
    settings = {
      # Automatically hard-link duplicate files in the store to save space
      auto-optimise-store = true;
      # Enable Flakes and new Nix commands
      experimental-features = [ "nix-command" "flakes" ];
    };
    # Set up automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # zram swap for efficient memory compression
  zramSwap.enable = true;

  # Firmware update service
  services.fwupd.enable = true;
}
