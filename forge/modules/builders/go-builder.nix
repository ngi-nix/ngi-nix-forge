{
  inputs,
  config,
  lib,
  flake-parts-lib,
  ...
}:

let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption (
      {
        config,
        pkgs,
        sharedBuildAttrs,
        ...
      }:
      {
        options = {
          forge.packages = lib.mkOption {
            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  build.goBuilder = {
                    enable = lib.mkEnableOption ''
                      Go module builder for applications and libraries.

                      Uses buildGoModule from nixpkgs under the hood.'';
                    requirements = {
                      native = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                        description = ''
                          Native build-time dependencies.

                          Use this for tools needed during the build, such as pkg-config.
                        '';
                        example = lib.literalExpression "[ pkgs.pkg-config pkgs.installShellFiles ]";
                      };
                      build = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                        description = ''
                          Build and runtime dependencies for the target platform.

                          Use this for libraries needed by cgo-enabled packages.
                        '';
                        example = lib.literalExpression "[ pkgs.openssl pkgs.sqlite ]";
                      };
                    };
                    vendorHash = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = "";
                      description = ''
                        Hash of the vendored Go module dependency tree.

                        Leave empty initially to let Nix print the correct hash on first build.
                      '';
                    };
                    modRoot = lib.mkOption {
                      type = lib.types.str;
                      default = ".";
                      description = ''
                        Relative path to the directory containing go.mod.

                        Useful for monorepos where the Go module is not at the repository root.
                      '';
                      example = "cmd/my-app";
                    };
                    subPackages = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      default = [ "." ];
                      description = ''
                        List of Go packages to build.

                        Keep the default for a single main package, or provide multiple package paths.
                      '';
                      example = [
                        "."
                        "./cmd/tool"
                      ];
                    };
                    ldflags = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      default = [ ];
                      description = ''
                        Linker flags passed to the Go compiler.

                        Commonly used to embed version information.
                      '';
                      example = [
                        "-s"
                        "-w"
                        "-X main.version=1.0.0"
                      ];
                    };
                    tags = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      default = [ ];
                      description = "Build tags passed to the Go compiler.";
                      example = [
                        "sqlite"
                        "netgo"
                      ];
                    };
                    proxyVendor = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = ''
                        Fetch dependencies via the Go module proxy instead of vendoring from source.

                        Enable this only when upstream vendoring is incomplete or unsuitable.
                      '';
                    };
                  };
                };
              }
            );
          };
        };

        config = {
          packages =
            let
              cfg = config.forge.packages;

              goBuilderPkgs = lib.listToAttrs (
                map (pkg: {
                  name = pkg.name;
                  value = pkgs.callPackage (
                    # Derivation start
                    { }:
                    pkgs.buildGoModule (
                      finalAttrs:
                      {
                        pname = pkg.name;
                        version = pkg.version;
                        src = sharedBuildAttrs.pkgSource pkg;
                        patches = pkg.source.patches;
                        vendorHash = pkg.build.goBuilder.vendorHash;
                        modRoot = pkg.build.goBuilder.modRoot;
                        subPackages = pkg.build.goBuilder.subPackages;
                        ldflags = pkg.build.goBuilder.ldflags;
                        tags = pkg.build.goBuilder.tags;
                        proxyVendor = pkg.build.goBuilder.proxyVendor;
                        nativeBuildInputs = pkg.build.goBuilder.requirements.native;
                        buildInputs = pkg.build.goBuilder.requirements.build;
                        passthru = sharedBuildAttrs.pkgPassthru pkg finalAttrs.finalPackage;
                        meta = sharedBuildAttrs.pkgMeta pkg;
                      }
                      // pkg.build.extraDrvAttrs
                      // lib.optionalAttrs pkg.build.debug sharedBuildAttrs.debugShellHookAttr
                    )
                    # Derivation end
                  ) { };
                }) (lib.filter (p: p.build.goBuilder.enable == true) cfg)
              );
            in
            goBuilderPkgs;
        };
      }
    );
  };
}
