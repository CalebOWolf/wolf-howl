{ ... }:

{
  services.udev.extraRules = ''
    # Keychron V1 (WebHID/WebUSB)
    SUBSYSTEM=="usb", ATTR{idVendor}=="3434", ATTR{idProduct}=="0310", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="3434", ATTR{idProduct}=="0313", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0310", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0313", TAG+="uaccess"

    # Pulsar X2 CrazyLight over USB cable and its 2.4 GHz receiver
    SUBSYSTEM=="usb", ATTR{idVendor}=="3710", ATTR{idProduct}=="3414", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="3710", ATTR{idProduct}=="5406", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3710", ATTRS{idProduct}=="3414", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3710", ATTRS{idProduct}=="5406", TAG+="uaccess"
  '';
}
