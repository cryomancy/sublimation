{
  lib,
  stdenv,
  bzip2,
  expat,
  git,
  pkg-config,
  zig_0_13,
  pandoc,
  revision ? "dirty",
  optimize ? "Debug",
}: let
  # The Zig hook has no way to select the release type without actual
  # overriding of the default flags.
  #
  # TODO: Once
  # https://github.com/ziglang/zig/issues/14281#issuecomment-1624220653 is
  # ultimately acted on and has made its way to a nixpkgs implementation, this
  # can probably be removed in favor of that.
  zig_hook = zig_0_13.hook.overrideAttrs {
    zig_default_flags = "-Dcpu=baseline -Doptimize=${optimize}";
  };

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.intersection (lib.fileset.fromSource (lib.sources.cleanSource ../.)) (
      lib.fileset.unions [
        ../src
      ]
    );
  };

  zigCache = stdenv.mkDerivation {
    inherit src;
    name = "sublimation-cache";
    nativeBuildInputs = [
      git
      zig_hook
    ];

    dontConfigure = true;
    dontUseZigBuild = true;
    dontUseZigInstall = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      sh ./nix/build-support/fetch-zig-cache.sh

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r --reflink=auto $ZIG_GLOBAL_CACHE_DIR $out

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = lib.fakeHash;
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "sublimation";
    version = "0.0.1";
    inherit src;

    nativeBuildInputs = [
      git
      pandoc
      pkg-config
      zig_hook
    ];

    buildInputs = [
      bzip2
      expat
    ];

    dontConfigure = true;

    zigBuildFlags = "-Dversion-string=${finalAttrs.version}-${revision}-nix";

    preBuild = ''
      rm -rf $ZIG_GLOBAL_CACHE_DIR
      cp -r --reflink=auto ${zigCache} $ZIG_GLOBAL_CACHE_DIR
      chmod u+rwX -R $ZIG_GLOBAL_CACHE_DIR
    '';

    outputs = [
      "out"
    ];

    meta = {
      homepage = "https://github.com/TahlonBrahic/sublimation";
      license = lib.licenses.mit;
      platforms = [
        "x86_64-linux"
      ];
      mainProgram = "sublimation";
    };
  })
