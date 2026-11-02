{ nixcordSource, pkgs, ... }:

let
  nixcordRevision = "f873f1e32925b870e68addeeb193fbc07e80a598";
  nixcord = import nixcordSource {
    nixpkgs = pkgs.path;
    revision = nixcordRevision;
  };
in
{
  imports = [ nixcord.nixosModules.nixcord ];

  programs.nixcord = {
    enable = true;
    user = "calebowolf";
    discord.enable = true;
    discord.vencord.enable = true;
    equibop.enable = true;
  };
}