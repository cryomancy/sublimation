{
  description = "Declare your Steam library with Nix";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eris = {
      url = "github:TahlonBrahic/eris";
    };
  };

  outputs =
    { nixpkgs, ... }:
    {
      devShells.x86_64-linux.default =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          packages = with pkgs; [
            zig_0_13
          ];
        };
      homeManagerModules.sublimation = _: {
        imports = [ ./modules ];
      };
    };
}
