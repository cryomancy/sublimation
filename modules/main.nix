{ config, lib, pkgs, ... }:

with import <nixpkgs> {};
let
  cfg = config.programs.sublimation;
  script = pkgs.writeShellApplication {
    name = "main";
    #TODO add runtime inputs
    runtimeInputs = [];
    text = (builtins.readFile ./main.sh);
  };
  #If we want to impliment external scripts without built inputs
  #mainScript =  pkgs.writeText "main.sh" (builtins.readFile ./main.sh);
in
{
home.activation.sublimation = (lib.hm.dag.entryAfter [ "writeBoundary" ]
      ''
       $DRY_RUN_CMD ${script}/bin/main
      '');
}