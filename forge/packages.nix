{ inputs, flake-parts-lib, ... }:

{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      forgeModules = [
        ./modules/apps
        ./modules/packages.nix
      ];

      evalForgeModules =
        modules:
        lib.evalModules {
          modules = modules;
          specialArgs = { inherit flake-parts-lib inputs; };
        };

      forgeOptionsDoc =
        modules:
        pkgs.nixosOptionsDoc {
          warningsAreErrors = false;
          options = lib.removeAttrs (evalForgeModules modules).options [ "_module" ];
          transformOptions =
            opt:
            opt
            // {
              name = lib.removePrefix "perSystem.forge." opt.name;
              declarations = [ ];
            };
        };

      forgeOptions = forgeOptionsDoc forgeModules;
    in
    {
      packages = {
        _forge-config = pkgs.writeTextFile {
          name = "forge-config.json";
          text = builtins.toJSON config.forge;
        };

        _forge-options = pkgs.runCommand "options.json" { } ''
          cp ${forgeOptions.optionsJSON}/share/doc/nixos/options.json $out
        '';

        _forge-ui = pkgs.callPackage ../ui/package.nix {
          inherit (config.packages) _forge-config _forge-options;
          buildElmApplication = (inputs.elm2nix.lib.elm2nix pkgs).buildElmApplication;
        };
      };

      forge.appsFilter =
        let
          optionNames = lib.attrNames forgeOptions.optionsNix;

          # NOTE: don't forget to update these, if they change
          commonOptions = [
            "apps.*.name"
            "apps.*.version"
            "apps.*.description"
            "apps.*.usage"
          ];

          filterOptions = pred: lib.filter pred optionNames;

          getOptions =
            appType:
            let
              pattern = "apps\\.\\*\\.${appType}(\\..+)?";
              matchedOptions = filterOptions (name: lib.match pattern name != null);
              combinedOptions = commonOptions ++ matchedOptions;
            in
            lib.unique combinedOptions;
        in
        lib.mkDefault (
          lib.genAttrs [
            "container"
            "nixos"
            "programs"
            "services"
          ] getOptions
        );

      forge.packagesFilter =
        let
          optionNames = lib.attrNames forgeOptions.optionsNix;

          # NOTE: don't forget to update these, if they change
          commonOptions = [
            "packages.*.name"
            "packages.*.version"
            "packages.*.source.git"
            "packages.*.source.patches"
            "packages.*.test.script"
          ];

          filterOptions = pred: lib.filter pred optionNames;

          getOptions =
            builderType:
            let
              pattern = "packages\\.\\*\\.build\\.${builderType}(\\..+)?";
              matchedOptions = filterOptions (name: lib.match pattern name != null);
              combinedOptions = commonOptions ++ matchedOptions;
            in
            lib.unique combinedOptions;
        in
        lib.mkDefault (
          lib.genAttrs [
            "standardBuilder"
            "pythonAppBuilder"
            "pythonPackageBuilder"
          ] getOptions
        );
    };
}
