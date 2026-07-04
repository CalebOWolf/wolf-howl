{ pkgs, ... }:

{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

      # Parallel build jobs (auto detects CPU count)
      max-jobs = "auto";
      cores = "auto";  # Fixed: was incorrectly set to 0
      
      # Limit parallel downloads to prevent network saturation
      max-substitution-jobs = 8;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      extra-sandbox-paths = [ "/var/cache/ccache" ];
      
      # Preserve build outputs for development workflows
      keep-outputs = true;
      keep-derivations = true;
    };
    
    gc = {
      automatic = true;
      dates = "weekly";  # Consider "daily" if disk space is limited
      options = "--delete-older-than 7d";
    };
  };

  # Compiler cache for faster rebuilds (requires ccache integration in build setup)
  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
  };

  zramSwap.enable = true;
  services.fwupd.enable = true;
}
