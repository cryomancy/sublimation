{ lib, ... }:
{
imports = [
./main.nix
];
options.programs.sublimation.enable = lib.mkEnableOption ''
    Enable declaritively installing steam games.
  '';
}