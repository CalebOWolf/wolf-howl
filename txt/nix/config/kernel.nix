{ pkgs, ... }:

{
  # Track the newest kernel package set available from the configured nixpkgs input.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    # Keep boot messages quiet and show the boot splash when configured.
    "quiet"
    "splash"
  ];
}
