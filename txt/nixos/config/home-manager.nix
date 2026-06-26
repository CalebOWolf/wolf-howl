{ config, pkgs, ... }:

{
  imports = [
    # Import the home-manager NixOS module.
    # Note: Since this configuration relies on standard Nix channels rather than flakes,
    # you must ensure that the home-manager channel is installed. If you haven't done
    # this already, run the following commands before applying/rebuilding the configuration:
    #
    # sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
    # sudo nix-channel --update
    <home-manager/nixos>
  ];

  # Use system packages and global nixpkgs settings for home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # User-specific home configuration
  home-manager.users.calebowolf = { pkgs, ... }: {
    home.stateVersion = "26.05";

    # Declarative Git configuration
    programs.git = {
      enable = true;
      userName = "Caleb Mignano";
      userEmail = "swagcalebwolf@gmail.com";
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
  };
}
