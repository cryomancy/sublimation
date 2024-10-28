{
  description = "Declare your Steam library with Nix";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.05";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems = { 
      url = "github:nix-systems/x86_64-linux";
    };
  };

  outputs = inputs@{ self, systems, nixpkgs, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
  {
    homeManagerModules.sublimation = { ... }: {
      imports = [ ./modules ];
    };

    /*
    packages = 

    checks = {
      default = nixpkgsFor.${system}.callPackage ./test/basic.nix {
        home-manager-module = inputs.home-manager.nixosModules.home-manager;
        sublimation = self.homeManagerModules.sublimation;
      };
    };

    devShells = forAllSystems (system: {
      default = nixpkgsFor.${system}.mkShell {
      buildInputs = with nixpkgsFor.${system}; [
            # TODO: add dependencies 
        ];
      };
    });
    */
  };

