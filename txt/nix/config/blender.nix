{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.blender.override {
      rocmSupport = true;
    })
  ];
}
