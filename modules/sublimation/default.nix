{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  cfg = config.sublimation;
  users = config.users.users;
  sublimation = cfg.package;
  manifestFor = pkgs.callPackage ./manifest-for.nix {
    inherit cfg;
    inherit (pkgs) writeTextFile;
  };
  manifest = manifestFor "sublimation" {};

  useSystemdActivation =
    (options.systemd ? sysusers && config.systemd.sysusers.enable)
    || (options.services ? userborn && config.services.userborn.enable);

  withEnvironment = import ./with-environment.nix {
    inherit cfg lib;
  };

  games = lib.types.submodule (
    {config, ...}: {
      config = {
      };
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = config._module.args.name;
          description = ''
          '';
        };
        appid = lib.mkOption {
          type = lib.types.str;
          default = null;
          description = ''
          '';
        };
        path = lib.mkOption {
          type = lib.types.path;
          default = null;
          description = ''
          '';
        };
        restartUnits = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["gamemode..service"];
          description = ''
            Names of units that should be restarted when sublimation makes changes.
            This works the same way as <xref linkend="opt-systemd.services._name_.restartTriggers" />.
          '';
        };
        reloadUnits = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["gamemode.service"];
          description = ''
            Names of units that should be reloaded when sublimation makes changes.
            This works the same way as <xref linkend="opt-systemd.services._name_.reloadTriggers" />.
          '';
        };
      };
    }
  );
in {
  options.sublimation = {
    library = lib.mkOption {
      type = lib.types.attrsOf games;
      default = {};
      description = ''
      '';
    };

    apiKeyPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Default API key used to interact with steam.
      '';
    };

    validateApiKey = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Check the API key at evaluation time.
        This requires the API key to be added to the nix store.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.str lib.types.path);
      default = {};
      description = ''
        Environment variables to set before calling sublimation-install-games.

        The values are placed in single quotes and not escaped any further to
        allow usage of command substitutions for more flexibility. To properly quote
        strings with quotes use lib.escapeShellArg.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.library != {}) {
      assertions =
        [
          {
            assertion =
              cfg.apiKeyPath != null;
            # || some way to check if user is already signed into steamcmd
            message = "No API key provided to sublimation.";
          }
        ]
        ++ lib.optionals cfg.validateApiKey (
          lib.concatLists (
            lib.mapAttrsToList (i: j: [
              {
                assertion = builtins.pathExists cfg.apiKeyPath;
                message = "Cannot find path '${cfg.apiKeyPath}' set in sublimation.apiKeyPath";
              }
              {
                assertion =
                  builtins.isPath cfg.apiKeyPath
                  || (builtins.isString cfg.apiKeyPath && lib.hasPrefix (builtins.storeDir cfg.apiKeyPath));
                message = "'${cfg.apiKeyPath}' is not in the Nix store. Either add it to the Nix store or set sublimation.validateApiKey to false";
              }
            ])
            cfg.apiKeyPath
          )
        );

      systemd.services.sublimation = lib.mkIf (cfg.library != {} && useSystemdActivation) {
        wantedBy = ["sysinit.target"];
        after = ["systemd-sysusers.service"];
        inherit (cfg) environment;
        unitConfig.DefaultDependencies = "no";
        PATH = let
          inherit (config.systemd.services.sublimation) path;
        in
          lib.mkForce "${lib.makeBinPath path}:${lib.makeSearchPathOutput "bin" "sbin" path}";
        systemd.services.sublimation.path = lib.lists.optionals (config.sublimation.environment ? PATH) (lib.pipe config.sublimation.environment.PATH [
          (lib.strings.splitString ":")
          (builtins.map (lib.strings.removeSuffix "/bin"))
        ]);

        serviceConfig = {
          Type = "oneshot";
          ExecStart = ["${cfg.package}/bin/sublimation ${manifest}"];
          RemainAfterExit = true;
        };
      };

      system.activationScripts = {
        installGames = lib.mkIf (cfg.library != {} && !useSystemdActivation) (
          lib.stringAfter
          [
            "specialfs"
            "users"
            "groups"
          ]
          ''
            [ -e /run/current-system ] || echo managing steam with sublimation...
            ${withEnvironment "${cfg.package}/bin/sublimation ${manifest}"}
          ''
          // lib.optionalAttrs (config.system ? dryActivationScript) {
            supportsDryActivation = true;
          }
        );
      };
    })
    {
      system.build.sublimation-manifest = manifest;
    }
  ];
}
