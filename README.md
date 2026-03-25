# Sublimation
'Transition of a substance directly from the solid to the gas state'

## Summary

Declare the desired output state of Steam (e.g. games) in your Nix configuration.

Sublimation = Solid (Flake) -> Gas (Steam)

<!-- TOC -->
- [Summary](#Summary)
- [Usage](#usage)
<!-- /TOC -->

## Project managers
@SpiderUnderUrBed
@TahlonBrahic

## Maintainers

## Usage
Given the restricted nature of steam, this does **NOT** install the games for you. Instead, this acts as a declarative link farm to a given directory. This can also be used to build mods for games as you would with Nix.

### Install with Flakes
1. Add sublimation as a input
2. Import it as a module
```nix
modules = [
  sublimation.homeManagerModules.sublimation
];
```
