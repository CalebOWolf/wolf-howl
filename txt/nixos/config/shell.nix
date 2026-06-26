{ pkgs, ... }:

{
  # Configure system-wide and user shell settings for Fish
  programs.fish = {
    # Custom aliases
    shellAliases = {
      ll = "ls -la";
      # NixOS shortcuts
      nix-boot = "sudo nixos-rebuild boot";
      nix-upgrade = "sudo nixos-rebuild boot --upgrade";
      nix-clean = "sudo nix-collect-garbage -d && nix-store --optimise";
    };

    # Custom shell initialization
    interactiveShellInit = ''
      # Disable the default Fish welcome greeting
      set fish_greeting ""
    '';
  };

  # Enable the Starship prompt system-wide (or can be configured in home-manager later)
  programs.starship = {
    enable = true;
  };
}
