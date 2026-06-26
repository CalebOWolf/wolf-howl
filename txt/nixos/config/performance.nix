{ pkgs, ... }:

{
  # Ananicy (Ana Nice Daemon) for automatic process prioritization.
  # Improves responsiveness of desktop apps and games under heavy CPU/IO load.
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };

  # TCP BBR Congestion Control & Fair Queueing (FQ)
  # Significantly improves network responsiveness, throughput, and reduces latency.
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
