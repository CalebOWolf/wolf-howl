{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  boot.kernelParams = [
    # AMD GPU & CPU settings (from amd.nix)
    "amd_pstate=active"
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.gpu_recovery=1"
    
    # Networking (from network.nix)
    "net.ifnames=0"
    "pcie_aspm=off"
    
    # NVMe Samsung (from samsung.nix)
    "nvme_core.default_ps_max_latency_us=0"
    
    # General/Performance additions
    "transparent_hugepage=never"  # More predictable latency under gaming workloads
    "quiet"              # Suppress boot messages
    "splash"             # Show splash screen if bootloader supports it
  ];
}
