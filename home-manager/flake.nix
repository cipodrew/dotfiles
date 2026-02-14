{
  description = "Home Manager configuration of cipo";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."serenity" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./serenity.nix ];
          # Optionally use extraSpecialArgs
          # to pass through arguments to module
        };

      homeConfigurations."bebop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./bebop.nix ];
        };
    };
}

