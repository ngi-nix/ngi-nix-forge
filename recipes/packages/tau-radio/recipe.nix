{
  config,
  pkgs,
  lib,
  ...
}:

{
  name = "tau-radio";
  version = "0.2.101-unstable-2025-12-17";
  description = "Web radio - Hijacks audio device using CLAP and Ogg/Opus";
  homePage = "https://github.com/tau-org/tau-radio";
  mainProgram = "tau-radio";
  license = lib.licenses.eupl12;

  source = {
    git = "github:tau-org/tau-radio/1847e4b4d91e941c19072752ed3afa95f2941a68";
    hash = "sha256-DW37p4FCK78Yk4KUtOcSfgjZGXhRytQA3/fR+ZkijxQ=";
  };

  build.rustPackageBuilder = {
    enable = true;
    requirements = {
      native = with pkgs; [
        pkg-config
        rustPlatform.bindgenHook
      ];
      build =
        with pkgs;
        [
          libogg
          libopus
          libopusenc
          libshout
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          alsa-lib
          jack2
        ];
    };
    cargoHash = "sha256-zqucj1iNsUdA06D+tDyYkevF/gio31JmcP00bk5PC18=";
  };

  build.extraDrvAttrs = {
    # fatal error: 'opus.h' file not found
    env.NIX_CFLAGS_COMPILE = "-I${pkgs.libopus.dev}/include/opus";
  };

  test.script = ''
    tau-radio --version
  '';
}
