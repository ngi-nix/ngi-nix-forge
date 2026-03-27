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
      { config, pkgs, ... }:
      let
        # Define shared build attributes here so they can be passed via _module.args
        sharedBuildAttrs = {
          pkgSource =
            let
              fetchers = {
                path = pkg: pkg.source.path;

                git =
                  pkg:
                  let
                    forges = {
                      # forge = fetchFunction
                      github = pkgs.fetchFromGitHub;
                      gitlab = pkgs.fetchFromGitLab;
                    };
                    parts = lib.splitString ":" pkg.source.git;
                    forge = lib.elemAt parts 0;
                    pathParts = lib.splitString "/" (lib.elemAt parts 1);
                    fetcher = forges.${forge} or null;
                  in
                  if fetcher != null then
                    fetcher {
                      owner = lib.elemAt pathParts 0;
                      repo = lib.elemAt pathParts 1;
                      rev = lib.elemAt pathParts 2;
                      hash = pkg.source.hash;
                    }
                  else
                    pkgs.fetchgit {
                      url = pkg.source.git;
                      hash = pkg.source.hash;
                    }
                    // lib.optionalAttrs (pkg.source ? tag) { inherit (pkg.source) tag; }
                    // lib.optionalAttrs (pkg.source ? rev) { inherit (pkg.source) rev; };

                url =
                  pkg:
                  pkgs.fetchurl {
                    url = pkg.source.url;
                    hash = pkg.source.hash;
                  };
              };

              # Determine which source type is used
              sourceType =
                pkg:
                if pkg.source.path != null then
                  "path"
                else if pkg.source.git != null then
                  "git"
                else
                  "url";
            in
            pkg: fetchers.${sourceType pkg} pkg;

          pkgPassthru = pkg: finalPkg: {
            test = pkgs.testers.runCommand {
              name = "${pkg.name}-test";
              buildInputs = [ finalPkg ] ++ pkg.test.requirements;
              script = pkg.test.script + "\ntouch $out";
            };
            devenv = pkgs.mkShell {
              env.DEVENV_PACKAGE_NAME = "${pkg.name}";
              env.DEVENV_PACKAGE_SOURCE = "${finalPkg.src}";
              inputsFrom = [
                finalPkg
              ];
              packages = pkg.development.requirements;
              shellHook = pkg.development.shellHook;
            };
          };

          pkgMeta = pkg: {
            description = pkg.description;
            mainProgram = pkg.mainProgram;
            license = pkg.license;
          };

          debugShellHookAttr = {
            shellHook = "source ${inputs.nix-utils}/nix-develop-interactive.bash";
          };
        };
      in
      {
        options = {
          # No options needed
        };

        config = {
          # Pass shared build attributes to other modules via _module.args
          _module.args.sharedBuildAttrs = sharedBuildAttrs;
        };
      }
    );
  };
}
