{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # Hardware Support Configuration
  # ============================================================================

  # Ensure redistributable hardware firmware is enabled
  hardware.enableRedistributableFirmware = true;

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
    # I/O Scheduler: MQ-Deadline optimized for NVMe (low latency, good throughput)
    "elevator=mq-deadline"
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
  # Network Tuning for TCP/IP Tunneling and Performance
  # ============================================================================
  # Consolidated network and performance tuning.
  # Using balanced settings optimized for both stability and low latency

  boot.kernel.sysctl = {
    # Congestion control & queue discipline (performance tuning)
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Socket buffer sizes (merged: performance values for lower latency on 2 Gbps)
    "net.core.rmem_default" = 131072;       # 128 KiB
    "net.core.rmem_max" = 16777216;         # 16 MiB
    "net.core.wmem_default" = 131072;       # 128 KiB
    "net.core.wmem_max" = 16777216;         # 16 MiB

    # TCP buffer sizes (merged: performance values for auto-scaling)
    "net.ipv4.tcp_rmem" = "8192 131072 16777216";
    "net.ipv4.tcp_wmem" = "8192 131072 16777216";

    # Maximum number of packets allowed in backlog queue
    # Increased for high-traffic scenarios to prevent packet drops
    "net.core.netdev_max_backlog" = 5000;

    # TCP performance tuning for gaming/realtime
    # NOTE: Aggressive reuse and low fin_timeout may break compatibility with
    # poorly-behaved servers; monitor for connection issues if they appear.
    "net.ipv4.tcp_tw_reuse" = 1;            # Reuse TIME_WAIT sockets faster
    "net.ipv4.tcp_fin_timeout" = 30;        # Faster connection cleanup

    # Disable TCP slow start after idle (bad for gaming)
    "net.ipv4.tcp_slow_start_after_idle" = 0;

    # TCP Fast Open: faster connection establishment (client + server modes)
    "net.ipv4.tcp_fastopen" = 3;

    # TCP retransmit tuning for faster failure detection in gaming scenarios
    "net.ipv4.tcp_retries2" = 5;

    # UDP buffer sizes for multiplayer gaming protocols
    "net.core.udp_mem" = "8388608 12582912 16777216";

    # Memory pressure: avoid unnecessary swap for responsive gaming
    "vm.swappiness" = 10;

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
  # CPU Governor Configuration
  # ============================================================================

  # CPU Governor: Performance mode for gaming (lower latency, consistent FPS)
  powerManagement.cpuFreqGovernor = "performance";

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
