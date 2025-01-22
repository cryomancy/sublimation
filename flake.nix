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

  outputs = inputs @ {nixpkgs, ...}: {
    homeManagerModules.sublimation = _: {
      imports = [./modules];
    };
  };
}
