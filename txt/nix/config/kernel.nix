{ ... }:

{
  boot.kernelParams = [
    # Network interface naming and PCIe power management.
    "net.ifnames=0"
    "pcie_aspm=off"

    # More predictable latency under gaming workloads.
    "transparent_hugepage=never"
    "quiet"
    "splash"
  ];
}
