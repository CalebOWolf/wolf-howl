{ config, pkgs, lib, ... }:

{
  # Ensure redistributable hardware firmware is enabled
  hardware.enableRedistributableFirmware = true;

  # ============================================================================
  # Hardware Support Configuration
  # ============================================================================

  # Intel I226-V Support (igc driver)
  # Load igc driver module early in boot and ensure kernel module is available
  boot.initrd.kernelModules = [ "igc" ];
  boot.kernelModules = [ "igc" "r8125" ];

  # Realtek RTL8125 Support (r8125 driver)
  # Blacklist the default in-kernel r8169 driver to prevent driver conflicts
  boot.blacklistedKernelModules = [ "r8169" ];

  # Use and build the proprietary/out-of-tree r8125 kernel module
  boot.extraModulePackages = [ config.boot.kernelPackages.r8125 ];

  # ============================================================================
  # Kernel Parameters
  # ============================================================================

  boot.kernelParams = [
    # Network interface naming: eth0, eth1, etc. (instead of enp0s3, etc.)
    # Provides consistent naming across reboots for scripting
    "net.ifnames=0"

    # PCIe Active State Power Management
    # Disabled for maximum stability; can be set to "performance" for aggressive power savings
    # Tradeoff: lower power consumption vs. potential link instability
    "pcie_aspm=off"
  ];

  # ============================================================================
  # Kernel Module Options
  # ============================================================================

  # Kernel driver options for r8125 stability:
  # - eee=0: Disable Energy Efficient Ethernet (can cause link drops and instability)
  # - aspm=0: Disable Active State Power Management at driver level
  boot.extraModprobeConfig = ''
    options r8125 eee=0 aspm=0
  '';

  # ============================================================================
  # Network Tuning for TCP/IP Tunneling Stability
  # ============================================================================

  boot.kernel.sysctl = {
    # Receive buffer sizes (default 128MB max, increased for high-throughput scenarios)
    "net.core.rmem_max" = 134217728;  # 128MB

    # Transmit buffer sizes (default 128MB max, increased for high-throughput scenarios)
    "net.core.wmem_max" = 134217728;  # 128MB

    # TCP receive buffer tuning: min, default, max
    # Allows kernel to dynamically adjust based on connection needs (up to 64MB)
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";

    # TCP transmit buffer tuning: min, default, max
    # Allows kernel to dynamically adjust based on connection needs (up to 64MB)
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";

    # Maximum number of packets allowed in backlog queue
    # Increased for high-traffic scenarios to prevent packet drops
    "net.core.netdev_max_backlog" = 5000;
  };

  # ============================================================================
  # Energy Efficient Ethernet (EEE) Management
  # ============================================================================
  # EEE can cause link drops and latency spikes on some Realtek NICs.
  # This service ensures EEE remains disabled at runtime and periodically re-enforces it.

  # Periodic timer to re-disable EEE (useful if NIC firmware re-enables it)
  systemd.timers.disable-eee = {
    description = "Periodically enforce EEE disable on ethernet interfaces";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Run 1 minute after boot
      OnBootSec = "1min";
      # Re-run every 5 minutes to catch any re-enabled EEE
      OnUnitActiveSec = "5min";
      # Persist timer state across reboots
      Persistent = true;
    };
  };

  # Runtime service to dynamically disable EEE on all ethernet interfaces
  systemd.services.disable-eee = {
    description = "Disable Energy Efficient Ethernet (EEE) on all ethernet interfaces";
    # Enable on multi-user boot
    wantedBy = [ "multi-user.target" ];
    # Ensure network is available before running
    after = [ "network.target" ];
    # Make this service available to the timer
    partOf = [ "disable-eee.timer" ];

    script = ''
      set -e
      echo "Starting EEE disable service..."

      for dev in /sys/class/net/*; do
        if [ ! -e "$dev" ]; then
          continue
        fi

        interface="''${dev##*/}"

        # Only process ethernet interfaces (en*, eth*)
        if [[ "$interface" =~ ^(en|eth) ]]; then
          echo "Disabling EEE on interface: $interface"
          ${pkgs.ethtool}/bin/ethtool --set-eee "$interface" eee off 2>/dev/null || {
            echo "Warning: Failed to disable EEE on $interface (may not support EEE)"
          }
        fi
      done

      echo "EEE disable service completed"
    '';

    serviceConfig = {
      # Run only once, don't restart
      Type = "oneshot";
      # Keep service marked as active after completion so timer can re-trigger it
      RemainAfterExit = true;
      # Run as root (required for ethtool)
      User = "root";
      # Standard output/error logging
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # ============================================================================
  # Configuration Assertions
  # ============================================================================

  assertions = [
    {
      assertion = config.boot.kernelPackages ? r8125;
      message = "r8125 kernel module is not available for the current kernel version. Ensure your kernel is compatible or update your NixOS configuration.";
    }
  ];
}
