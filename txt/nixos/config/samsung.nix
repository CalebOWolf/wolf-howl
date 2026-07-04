{ config, pkgs, lib, ... }:

{
  # Samsung 990 Pro NVMe SSD Optimizations

  # 1. Enable periodic TRIM to maintain SSD performance and longevity
  services.fstrim.enable = lib.mkDefault true;

  # 2. Kernel parameters for stability and performance
  boot.kernelParams = [
    # Allow low-power states with reasonable latency (safer than disabling entirely)
    "nvme_core.default_ps_max_latency_us=25000"
    # Writeback delay: default 500ms is usually sufficient for NVMe
    # Only increase if experiencing specific I/O stalls
    # "writeback_delay=800"
  ];

  # 3. I/O Scheduler Rule
  services.udev.extraRules = ''
    # Set NVMe I/O scheduler to 'none' (device-level, not partitions)
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]", SUBSYSTEM=="block", ATTR{queue/scheduler}="none"
    # Increase read-ahead buffer for sequential performance
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]", SUBSYSTEM=="block", ATTR{queue/read_ahead_kb}="256"
  '';

  # 4. Enable active S.M.A.R.T. disk health monitoring
  services.smartd.enable = lib.mkDefault true;
  services.smartd.devices = [
    {
      device = "/dev/nvme0n1";
      options = "-a -o on -S on -n standby,q -W 0,40,45";
    }
  ];

  # 5. NVMe monitoring and diagnostic utilities
  environment.systemPackages = with pkgs; [
    nvme-cli
    smartmontools
  ];

  # 6. Optional: CPU frequency scaling for power efficiency
  # powerManagement.cpuFreqGovernor = "powersave";
}
