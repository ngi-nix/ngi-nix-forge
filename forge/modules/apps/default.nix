{
  lib,
  inputs,
  flake-parts-lib,
  ...
}:

let
  inherit (flake-parts-lib)
    mkPerSystemOption
    ;
in

{
  imports = [
    ../assertions-warnings.nix
  ];

  options = {
    perSystem = mkPerSystemOption (
      {
        config,
        pkgs,
        nimi,
        system,
        ...
      }:
      let
        cfg = config.forge.apps;
      in
      {
        options = {
          forge = {
            appsFilter = lib.mkOption {
              internal = true;
              type = lib.types.attrsOf (lib.types.listOf lib.types.str);
              description = "Defines which options are relevant for each app output type.";
            };

            apps = lib.mkOption {
              default = [ ];
              description = "List of applications.";
              type = lib.types.listOf (
                lib.types.submoduleWith {
                  specialArgs = {
                    inherit
                      inputs
                      pkgs
                      nimi
                      system
                      ;
                  };
                  modules = [ ./app.nix ];
                }
              );
            };
          };
        };

        config =
          let
            shellBundle =
              app:
              let
                appDrv = pkgs.symlinkJoin {
                  name = "${app.name}-${app.version}";
                  paths = app.programs.requirements;
                };
              in
              # Passthru
              appDrv.overrideAttrs (_: {
                passthru = appPassthru app appDrv;
              });

            appPassthru =
              # finalApp parameter is currently not used in this function
              app: finalApp:
              { }
              // lib.optionalAttrs app.container.enable { container = app.container.result.imageBuilder; }
              // lib.optionalAttrs app.nixos.enable { vm = app.nixos.result.build; };

            allApps = lib.listToAttrs (
              map (app: {
                name = "${app.name}";
                value = shellBundle app;
              }) cfg
            );
          in
          {
            packages = allApps;
          };
      }
    );
  };
}
