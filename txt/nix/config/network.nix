{ ... }:

{
  hardware.enableRedistributableFirmware = true;

  # ASUS B550-F WiFi II onboard Intel I225-V and TP-Link TX201 Ethernet.
  boot.kernelModules = [ "igc" "r8169" ];
}
