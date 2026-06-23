{ config, pkgs, lib, ... }:

{
  # AMD CPU (Ryzen) Optimizations
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable the AMD P-State Scaling Driver for better power efficiency and performance
  # on modern Ryzen processors (Zen 2 and newer).
  boot.kernelParams = [ "amd_pstate=active" ];

  # AMD GPU (Radeon RX) Optimizations
  # Enable early KMS (Kernel Mode Setting) to load amdgpu driver early in boot,
  # preventing screen flickering and helping Wayland start smoothly.
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Hardware acceleration settings for graphics and compute
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd # OpenCL/HIP support for compute tasks (e.g. Blender)
      libvdpau-va-gl       # VDPAU driver wrapper for VA-API
    ];
  };

  # Fix for programs with hard-coded ROCm/HIP paths (like Blender)
  systemd.tmpfiles.rules = [
    "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
  ];

  # Enable LACT (Linux AMDGPU Controller) daemon for overclocking, power profiles, and fan curves
  services.lact.enable = true;

  # AMD specific performance monitoring and utility packages
  environment.systemPackages = with pkgs; [
    lact                # GUI and CLI client for LACT daemon
    amdgpu_top          # CLI tool showing real-time AMD GPU metrics
    nvtopPackages.amd   # Interactive GPU process monitor (AMD variant)
    clinfo              # Prints OpenCL platform and device information
  ];
}
