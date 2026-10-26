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

## Validate and activate

After placing the files in `/etc/nixos/` and adding the generated hardware
configuration, evaluate and build before switching:

```sh
sudo nixos-rebuild dry-build -I nixos-config=/etc/nixos/configuration.nix
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix
```

Keep `system.stateVersion` at the value used by the existing installation.
