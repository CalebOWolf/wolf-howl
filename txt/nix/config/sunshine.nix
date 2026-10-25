{ pkgs, ... }:

{
  # Enable Sunshine, the self-hosted game stream host for Moonlight.
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # Required for KMS screen grabbing and input emulation on Wayland/Plasma
    openFirewall = true; # Opens necessary UDP/TCP ports for Sunshine streaming
  };

  # Enable the uinput driver for virtual input emulation (mouse, keyboard, controller)
  hardware.uinput.enable = true;

  # Add user to the uinput group to allow Sunshine to emulate input devices
  users.users.calebowolf.extraGroups = [ "uinput" ];

  # Explicitly declare uinput group just in case
  users.groups.uinput = { };

  # Configure udev rules to ensure members of the uinput group can access the device node
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';
}
