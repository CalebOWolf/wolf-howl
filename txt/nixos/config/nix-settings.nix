{ pkgs, ... }:

{
  # Nix package manager settings
  nix = {
    settings = {
      # Automatically hard-link duplicate files in the store to save space
      auto-optimise-store = true;
      # Enable Flakes and new Nix commands
      experimental-features = [ "nix-command" "flakes" ];

      # Maximize CPU core usage for compilations
      max-jobs = "auto";
      cores = 0; # Use all CPU cores/threads for each job

      # Add community binary caches to avoid building from source
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Required sandbox paths for ccache
      extra-sandbox-paths = [ "/var/cache/ccache" ];
    };
    # Set up automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Enable compiler cache (ccache) system-wide
  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
  };

  # zram swap for efficient memory compression
  zramSwap.enable = true;

  # Firmware update service
  services.fwupd.enable = true;
}
