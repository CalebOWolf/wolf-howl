{ config, pkgs, lib, ... }:

{
  # Samsung 990 Pro NVMe SSD Optimizations

  # 1. Enable periodic TRIM to maintain SSD performance and longevity
  services.fstrim.enable = lib.mkDefault true;

  # 2. Kernel parameters for stability and performance
  # nvme_core.default_ps_max_latency_us: Controls Active Power State Transition (APST)
  #   - Value 0: Disables APST entirely (maximum stability, highest power consumption)
  #   - Value 25000+: Allows low-power states with latency guarantee (recommended for most users)
  #   - The Samsung 980/990 Pro is known for APST-related device drop-offs; adjust based on your needs
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0"
    # Increase write-back cache timeout for better performance (default is 500ms)
    "writeback_delay=1500"
  ];

  # 3. I/O Scheduler Rule
  # Use 'none' scheduler for NVMe devices to bypass CPU-bound I/O bottlenecks.
  # Multi-queue NVMe drives perform best without a traditional scheduler layer.
  services.udev.extraRules = ''
    # Set NVMe I/O scheduler to 'none'
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
    # Increase read-ahead buffer for sequential performance
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/read_ahead_kb}="256"
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
    nvme-cli             # NVMe management, firmware, and monitoring utility
    smartmontools        # S.M.A.R.T. monitoring for disk health
  ];

  # 6. Optional: Enable CPU frequency scaling for power efficiency
  # Uncomment if you want dynamic CPU scaling alongside the I/O optimizations
  # powerManagement.cpuFreqGovernor = "powersave";
}
