{ config, pkgs, lib, ... }:

{
  # Samsung NVMe health and maintenance

  # Enable periodic TRIM to maintain SSD performance and longevity.
  services.fstrim.enable = lib.mkDefault true;

  # Monitor all detected disks rather than relying on a device enumeration order.
  services.smartd = {
    enable = lib.mkDefault true;
    autodetect = true;
    defaults.monitored = "-a -o on -S on -n standby,q -W 0,40,45";
  };

  environment.systemPackages = with pkgs; [
    nvme-cli
    smartmontools
  ];
}
