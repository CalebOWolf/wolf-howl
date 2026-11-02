# NixOS configuration

The modular configuration entry point is `config/configuration.nix`. Copy the
contents of `config/` into `/etc/nixos/` so the flake, entry point, and imported
modules are together and their relative imports resolve. The checked-in
`config/flake.lock` pins the flake inputs; keep it with the configuration.

## What the flake does

If you are used to Arch, you may be used to installing a package with `pacman`
and having that change the machine right away. NixOS can work differently:
instead of treating the installed system as a list of changes made over time,
you describe the system you want in configuration files, then ask NixOS to
build and activate that described system.

A **flake** is the project's starting point for that process. In this
configuration, `flake.nix` says which external sources to use and defines the
system Nix should produce. The `nixpkgs` input is the collection of packages
and NixOS modules—roughly comparable to package repositories, but pinned to a
specific snapshot here. The configuration modules say what to enable or
install, and the flake exposes the resulting system as `wolfhowlnixos`.

The accompanying `flake.lock` records the exact versions of those sources.
Keeping it means a rebuild uses the same pinned revisions rather than
automatically moving to newer ones. To intentionally update those sources, run
the update/upgrade procedure below: refresh the inputs, review the lock-file
changes, then rebuild and activate the system.

This configuration follows the rolling `nixos-unstable` Nixpkgs branch.
Home Manager tracks its rolling `master` branch, and its nixpkgs input follows
the system's pinned nixpkgs. The lock file still pins exact revisions, so
changing a branch does not update packages by itself; run `nix flake update`
to refresh the pins, then review the lock-file changes before rebuilding.
Unstable can include breaking changes, so test with a dry build and keep a
working system generation available for rollback.

Home Manager is included as a NixOS module in the flake. NixOS continues to
manage the machine, while `config/home.nix` is the starting point for managing
Caleb's user-level settings, packages, and dotfiles. Its initial configuration
only enables Home Manager; add user-specific settings there as you choose what
you want Nix to manage.

To apply the configuration, run
`sudo nixos-rebuild switch --flake /etc/nixos#wolfhowlnixos`. This tells NixOS
to use the flake in `/etc/nixos`, build its `wolfhowlnixos` system, and activate
it. Changes to packages or system settings are normally made in the
configuration files and applied with this command, rather than by installing
them directly with `pacman`. NixOS keeps system generations, so you can select
an earlier generation from the boot menu if a newly activated system has a
problem.

## Update or upgrade the system

In this flake-based setup, **update** and **upgrade** mean the same workflow:
refresh the pinned package and module sources, then build and activate the full
system. `nix flake update` alone only changes the lock file; it does not change
the running system. Run:

```sh
cd /etc/nixos
nix flake update
sudo nixos-rebuild dry-build --flake /etc/nixos#wolfhowlnixos
sudo nixos-rebuild switch --flake /etc/nixos#wolfhowlnixos
```

Review the `flake.lock` changes after updating. The `dry-build` checks that the
system can be built without activating it; `switch` then builds and activates
the updated system. Reboot if the updated kernel or system services require it.
Do not substitute `nixos-rebuild --upgrade`: that option updates the root
user's `nixos` channel, not this flake's inputs.

`sudo nixos-rebuild dry-build --flake /etc/nixos#wolfhowlnixos` builds without
activating the result. `nix flake check --no-build` checks the flake without
building its outputs. Flakes are enabled in `nix-settings.nix` because they
are still an experimental Nix feature.

## Machine-specific setup

The configuration imports `hardware-configuration.nix`, which is generated
for the target machine and is intentionally not checked into this repository.
Place the target machine's generated file beside `configuration.nix` in
`/etc/nixos/`. `host-hardware.nix` groups the AMD CPU/GPU, motherboard and
TP-Link TX201 networking, and Samsung NVMe modules for this machine; remove or
adjust those imports when using different hardware. The ASUS ROG Strix B550-F
Gaming WiFi II's Intel I225-V Ethernet uses the in-kernel `igc` driver; the
TP-Link TX201's Realtek 2.5GbE controller uses the in-kernel `r8169` driver.
Both are loaded by `network.nix`, without an out-of-tree `r8125` module or
blacklisting `r8169`. The motherboard's Wi-Fi 6E and Bluetooth are handled by
the kernel's device drivers, with redistributable firmware enabled in
`network.nix`. `networking.nix` also sets this machine's hostname and enables
its network services. `input-devices.nix` grants the active desktop user
browser access to the Keychron V1 and Pulsar X2 CrazyLight USB/HID interfaces.
Google Chrome is included for browser-based device configurators that require
WebHID; open the configurator in Chrome and approve the device in its USB/HID
permission prompt. Firefox remains the default browser.

Discord is managed by the Nixcord NixOS module with Vencord enabled. The
upstream source is pinned to commit
`f873f1e32925b870e68addeeb193fbc07e80a598` in `config/flake.lock`.

The gaming module enables Steam with 32-bit graphics, Steam Input support,
GameMode, Gamescope, and Proton-GE. It opens Steam Remote Play's firewall ports,
including LAN peer discovery, so this PC can host Steam Link clients such as
Steam Frame.

To use Steam Frame, enable Remote Play in the Steam client's settings on this
PC, keep Steam running, and connect the headset and PC to the same non-isolated
LAN. For best streaming reliability, connect the PC to the router or access
point over Ethernet and use a strong 5 GHz or 6 GHz Wi-Fi connection for the
headset. For PC VR, install SteamVR from the Steam client and launch it through
Steam Link. Steam Frame does not need a headset-specific NixOS driver on the
host; SteamVR and individual games still need to support Linux. WiVRn is a
separate streaming path for compatible Android-based VR headsets, not a
replacement for Steam Link. WayVR and VRCX are included as system packages for
desktop/VR integration and VRChat companion features. The system packages also
include Android platform tools (`adb` and `fastboot`) and `scrcpy` for Android
device mirroring and control.

Blender is managed separately in `config/blender.nix` and built with ROCm/HIP
support for Cycles GPU rendering. The AMD module supplies the ROCm CLR ICD
through `hardware.graphics.extraPackages`.

Flatpak remotes and applications are installed by systemd services. A failed
install is reported by the unit and retried on a later boot; it can also be
retried manually with `sudo systemctl start flatpak-install.service`.

Kernel, NVMe, and network performance overrides that were not tied to a
measured problem have been removed. The system uses the kernel defaults for
interface names, PCIe power management, CPU scaling, NVMe scheduling, and TCP
tuning.

## Validate and activate

After placing the files in `/etc/nixos/` and adding the generated hardware
configuration, evaluate and build before switching:

```sh
cd /etc/nixos
alejandra --check flake.nix home.nix host-hardware.nix network.nix samsung.nix
nix flake update
nix flake check --no-build
sudo nixos-rebuild dry-build --flake /etc/nixos#wolfhowlnixos
sudo nixos-rebuild switch --flake /etc/nixos#wolfhowlnixos
```

Keep `system.stateVersion` at the value used by the existing installation.
