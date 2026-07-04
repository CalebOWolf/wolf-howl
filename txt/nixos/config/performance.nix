{ pkgs, ... }:

{
  # Disable Ananicy - not noticeable for gaming and adds overhead
  # services.ananicy.enable = false;

  # CPU Governor: Performance mode for gaming (lower latency, consistent FPS)
  powerManagement.cpuFreqGovernor = "performance";

  # I/O Scheduler: MQ-Deadline optimized for NVMe (low latency, good throughput)
  boot.kernelParams = [ "elevator=mq-deadline" ];

  # Network tuning: BBR congestion control + fair queuing + optimized buffers
  # Tuned for 2 Gbps fiber connection
  boot.kernel.sysctl = {
    # Congestion control & queue discipline
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Socket buffer sizes (optimized for 2 Gbps - lower latency, less memory waste)
    "net.core.rmem_default" = 131072;       # 128 KiB
    "net.core.rmem_max" = 16777216;         # 16 MiB
    "net.core.wmem_default" = 131072;       # 128 KiB
    "net.core.wmem_max" = 16777216;         # 16 MiB

    # TCP buffer sizes (auto-scaling between min, default, max)
    "net.ipv4.tcp_rmem" = "8192 131072 16777216";
    "net.ipv4.tcp_wmem" = "8192 131072 16777216";

    # TCP performance tuning for gaming/realtime
    "net.ipv4.tcp_tw_reuse" = 1;            # Reuse TIME_WAIT sockets faster
    "net.ipv4.tcp_fin_timeout" = 30;        # Faster connection cleanup
    "net.core.netdev_max_backlog" = 5000;   # Higher backlog for bursty traffic

    # Disable TCP slow start after idle (bad for gaming)
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };

  # Optional: Disable transparent hugepages for more predictable gaming latency
  # vm.transparent_hugepage = "never";
}
