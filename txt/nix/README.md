# NixOS configuration

The modular configuration entry point is `config/configuration.nix`. Copy the
contents of `config/` into `/etc/nixos/` so the entry point and its imported
modules are together and their relative imports resolve.

## Machine-specific setup

The configuration imports `hardware-configuration.nix`, which is generated
for the target machine and is intentionally not checked into this repository.
Place the target machine's generated file beside `configuration.nix` in
`/etc/nixos/`. The networking, AMD, and Samsung modules also assume the
corresponding hardware is present; adjust those imports for a different
machine.

Discord is managed by the Nixcord NixOS module with Vencord enabled. The
upstream source is pinned to commit
`f873f1e32925b870e68addeeb193fbc07e80a598` in `config/nixcord.nix`.

The gaming module installs WiVRn for streaming PC VR to a standalone headset.
The system packages include Android platform tools (`adb` and `fastboot`) and
`scrcpy` for Android device mirroring and control.

## Validate and activate

After placing the files in `/etc/nixos/` and adding the generated hardware
configuration, evaluate and build before switching:

```sh
sudo nixos-rebuild dry-build -I nixos-config=/etc/nixos/configuration.nix
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix
```

Keep `system.stateVersion` at the value used by the existing installation.
