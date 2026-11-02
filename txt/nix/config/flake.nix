{
  description = "NixOS configuration for wolfhowlnixos";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.nixcord = {
    url = "github:4evy/nixcord/f873f1e32925b870e68addeeb193fbc07e80a598";
    flake = false;
  };

  outputs = { nixpkgs, home-manager, nixcord, ... }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    nixosConfigurations.wolfhowlnixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { nixcordSource = nixcord; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.calebowolf = import ./home.nix;
        }
      ];
    };
  };
}
