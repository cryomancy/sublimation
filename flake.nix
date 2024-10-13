{
  description = "Lets users automatically change wallpapers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, ... }:
    let
      # Systems that can run tests:
      supportedSystems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];

      # Function to generate a set based on supported systems:
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system:
        import inputs.nixpkgs { inherit system; });
    in
    {
      homeManagerModules.sublimation = { ... }: {
        imports = [ ./modules ];
      };

      #TODO Decide wheter or not to implement packages
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in
        {

        });

      #TODO Decide wheter or not to implement apps
      apps = forAllSystems (system: {
        #default = self.apps.${system}.;
      });

      checks = forAllSystems (system:
        {
          default = nixpkgsFor.${system}.callPackage ./test/basic.nix {
            home-manager-module = inputs.home-manager.nixosModules.home-manager;
            sublimation = self.homeManagerModules.sublimation;
          };
        });

      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          buildInputs = with nixpkgsFor.${system}; [
            #TODO add dependencies
          ];
        };
      });
    };
}
