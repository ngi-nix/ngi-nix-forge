# From Nixpkgs' buildRustPackage:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/rust/build-rust-package/default.nix

{
  lib,
  ...
}:
{
  options.build.rustPackageBuilder = {
    enable = lib.mkEnableOption ''
      Rust package builder for reusable Rust crates.

      Uses rustPlatform.buildRustPackage'';

    requirements = {
      native = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = ''
          Build-time dependencies (native architecture).

          Tools needed during compilation that run on the build machine.
        '';
        example = lib.literalExpression "[ pkgs.pkg-config pkgs.rustPlatform.bindgenHook ]";
      };
      build = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = ''
          Runtime dependencies (target architecture).

          Libraries needed by the package at runtime.
        '';
        example = lib.literalExpression "[ pkgs.openssl pkgs.sqlite pkgs.libopus ]";
      };
    };

    cargoHash = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        SHA256 hash of the Cargo.lock file or source.

        For git sources without Cargo.lock, this is the source hash.
        Leave empty initially - nix will provide the correct hash on first build.
      '';
      example = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    cargoBuildFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Additional flags to pass to cargo build.
      '';
      example = [
        "--release"
        "--features enable-feature"
      ];
    };
  };
}
