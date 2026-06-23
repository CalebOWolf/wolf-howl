{ config, pkgs, ... }:

{
  # Ensure redistributable hardware firmware is enabled
  hardware.enableRedistributableFirmware = true;

  # Intel I226-V Support (igc driver)
  # Load igc driver module early in boot and ensure kernel module is available
  boot.initrd.kernelModules = [ "igc" ];
  boot.kernelModules = [ "igc" ];

  # Realtek RTL8125 Support (r8125 driver)
  # Blacklist the default in-kernel r8169 driver to prevent driver conflicts
  boot.blacklistedKernelModules = [ "r8169" ];
  # Use and build the proprietary/out-of-tree r8125 kernel module
  boot.extraModulePackages = [ config.boot.kernelPackages.r8125 ];
  boot.kernelModules = [ "r8125" ];

  # Kernel driver options for r8125 stability:
  # - Disable Energy Efficient Ethernet (eee=0)
  # - Disable Active State Power Management (aspm=0)
  boot.extraModprobeConfig = ''
    options r8125 eee=0 aspm=0
  '';

  # Runtime service to dynamically disable EEE on all ethernet interfaces
  systemd.services.disable-eee = {
    description = "Disable Energy Efficient Ethernet (EEE) on all ethernet interfaces";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.ethtool ];
    script = ''
      for dev in /sys/class/net/*; do
        if [ -e "$dev" ]; then
          interface=''${dev##*/}
          if [[ "$interface" =~ ^(en|eth) ]]; then
            echo "Disabling EEE on ethernet interface: $interface"
            ethtool --set-eee "$interface" eee off || true
          fi
        fi
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
