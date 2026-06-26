{ config, pkgs, ... }:

{
  # Secrets Management Tooling Setup Guide
  #
  # This file serves as a template / placeholder showing how to integrate
  # sops-nix or agenix for declarative, git-crypt-free secrets management.
  # 
  # Note: The 'sops' and 'age' packages are installed system-wide in system-packages.nix.
  #
  # --- Setting up sops-nix ---
  #
  # 1. Add sops-nix module to your configuration imports (e.g. if using flakes or channels).
  #    For standard channel-based setups, you'd run:
  #    sudo nix-channel --add https://github.com/Mic92/sops-nix/archive/master.tar.gz sops-nix
  #    sudo nix-channel --update
  #
  # 2. Uncomment and configure the block below:
  #
  # imports = [ <sops-nix/modules/sops> ];
  #
  # sops = {
  #   # Path to the encrypted yaml/json file in this repository
  #   defaultSopsFile = ./secrets.yaml;
  #
  #   # Path to the age key file used to decrypt the secrets
  #   age.keyFile = "/home/calebowolf/.config/sops/age/keys.txt";
  #
  #   # Declaratively define your secrets. They will be decrypted into /run/secrets/
  #   secrets = {
  #     # Example: a user password
  #     user-password = {
  #       neededForUsers = true; # decrypt early during boot for user login
  #     };
  #     # Example: Tailscale auth key
  #     tailscale-key = {};
  #   };
  # };
  #
  # --- Usage in other files ---
  #
  # Referencing the decrypted credentials (which exist under /run/secrets/):
  #
  # users.users.calebowolf.hashedPasswordFile = config.sops.secrets.user-password.path;
  #
}
