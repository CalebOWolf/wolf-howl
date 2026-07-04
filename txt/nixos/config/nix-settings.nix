{ pkgs, ... }:

{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = true;  # Warn when flakes have uncommitted changes

      # Parallel build jobs (auto detects CPU count)
      # Note: "auto" uses all cores; consider reducing for system responsiveness
      max-jobs = "auto";
      
      # Limit parallel downloads to prevent network saturation
      max-substitution-jobs = 4;

      # Cache servers with priority (lower number = higher priority)
      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org?priority=20"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Enable CPU-specific optimizations where available
      system-features = [ "nixos-test" "benchmark" "big-parallel" ];

      extra-sandbox-paths = [ "/var/cache/ccache" ];
      
      # Development workflow settings
      # WARNING: keep-outputs and keep-derivations can consume significant disk space
      # Set to false to allow garbage collection to reclaim space
      keep-outputs = false;
      keep-derivations = false;

      # Security: restrict Nix daemon access to wheel group
      allowed-users = [ "@wheel" ];
    };
    
    gc = {
      automatic = true;
      dates = "weekly";
      # Tune to "daily" with "3d" if disk space is limited
      options = "--delete-older-than 7d";
    };
  };

  # Compiler cache for faster rebuilds (requires ccache integration in build setup)
  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
  };

  # System-level performance and hardware settings
  zramSwap.enable = true;
  services.fwupd.enable = true;
}
