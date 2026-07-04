{ config, pkgs, lib, ... }:

{
  # AMD CPU (Ryzen) Optimizations
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable the AMD P-State Scaling Driver for better power efficiency and performance
  # on modern Ryzen processors (Zen 2 and newer).
  boot.kernelParams = [ 
    "amd_pstate=active"
    # Uncomment the line below for power-saving mode instead of performance-focused
    # "amd_pstate.prefer_performance_mode=0"
    # Unlocks OverDrive features (overclocking/undervolting/fan control) for LACT
    "amdgpu.ppfeaturemask=0xffffffff"
    # Enable GPU driver recovery to automatically reset the GPU instead of freezing the system on hang
    "amdgpu.gpu_recovery=1"
    # Uncomment for cutting-edge hardware with experimental GPU features
    # "amdgpu.exp_hw_support=1"
  ];

  # CPU frequency scaling governor
  # Options: "powersave", "performance", "ondemand", "conservative"
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # AMD GPU (Radeon RX) Optimizations
  # Enable early KMS (Kernel Mode Setting) to load amdgpu driver early in boot,
  # preventing screen flickering and helping Wayland start smoothly.
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  # Video driver configuration (primarily for X11; Wayland uses different loading mechanism)
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Hardware acceleration settings for graphics and compute
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # OpenCL/HIP support for compute tasks (e.g., Blender, scientific computing)
      rocmPackages.clr.icd
      # VA-API and VDPAU support for hardware video decode/encode
      libva
      libva-vdpau-driver
      libvdpau-va-gl
      # Vulkan support for modern graphics applications and games
      vulkan-tools
      vulkan-loader
    ];
  };

  # Environment variables for GPU compute tasks (optional, uncomment if needed)
  # environment.variables = {
  #   HSA_OVERRIDE_GFX_VERSION = "";  # Uncomment if you need to override GPU detection
  # };

  # Enable LACT (Linux AMDGPU Controller) daemon for overclocking, power profiles, and fan curves
  services.lact.enable = lib.mkDefault true;

  # AMD specific performance monitoring and utility packages
  environment.systemPackages = with pkgs; [
    lact                # GUI and CLI client for LACT daemon
    amdgpu_top          # CLI tool showing real-time AMD GPU metrics
    nvtopPackages.amd   # Interactive GPU process monitor (AMD variant)
    clinfo              # Prints OpenCL platform and device information
  ];
}
