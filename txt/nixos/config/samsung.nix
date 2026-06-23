{ config, pkgs, lib, ... }:

{
  # Samsung 990 Pro NVMe SSD Optimizations

  # 1. Enable periodic TRIM to maintain SSD performance and longevity
  services.fstrim.enable = lib.mkDefault true;

  # 2. Kernel parameters for stability
  # Disables deep power-saving states (Active Power State Transition - APST)
  # which are known to cause device drop-offs and system freezes on Samsung 980/990 Pro drives.
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0"
  ];

  # 3. I/O Scheduler Rule
  # Use 'none' scheduler for NVMe devices to bypass CPU-bound I/O bottlenecks.
  # Multi-queue NVMe drives perform best without a traditional scheduler layer.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
  '';

  # 4. NVMe monitoring and diagnostic utilities
  environment.systemPackages = with pkgs; [
    nvme-cli             # NVMe management and firmware information utility
    smartmontools        # S.M.A.R.T. monitoring for disk health
  ];
}
