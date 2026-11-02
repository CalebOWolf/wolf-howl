{ config, pkgs, lib, ... }:

{
  # AMD CPU (Ryzen) Optimizations
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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
      # Compute & HIP support for GPGPU tasks
      rocmPackages.clr.icd
      
      # Video decode/encode support
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

  # Enable LACT (Linux AMDGPU Controller) daemon for fan control, power profiles, and monitoring
  services.lact.enable = lib.mkDefault true;

  # AMD specific performance monitoring and utility packages
  environment.systemPackages = with pkgs; [
    lact                # GUI and CLI client for LACT daemon
    amdgpu_top          # CLI tool showing real-time AMD GPU metrics
    nvtopPackages.amd   # Interactive GPU process monitor (AMD variant)
    clinfo              # Prints OpenCL platform and device information
  ];

  # Wayland-specific optimizations (uncomment if using a Wayland compositor like Sway or Hyprland)
  # environment.sessionVariables = {
  #   WLR_RENDERER = "vulkan";  # Use Vulkan for wlroots compositors for better performance
  # };
}
