{
  config,
  lib,

  nimi,
  app,
  pkgs,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "container image output";

    name = lib.mkOption {
      type = lib.types.str;
      default = "container";
      description = "Name of the generated container.";
    };

    tag = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "Tag of the generated container.";
    };

    requirements = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "List of packages to add to the container's `/bin` directory.";
      apply =
        self:
        (pkgs.buildEnv {
          name = "runtime-bins";
          paths = self;
          pathsToLink = [ "/bin" ];
        });
    };

    # NOTE: config is reserved by the module system
    imageConfig = lib.mkOption {
      type = with lib.types; lazyAttrsOf anything;
      default = { };
      description = ''
        OCI image configuration as specified in <https://specs.opencontainers.org/image-spec/config/#properties>.
      '';
    };

    composeFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the application container's compose file.";
    };

    result = {
      nimi = lib.mkOption {
        internal = true;
        type = with lib.types; lazyAttrsOf (either attrs anything);
        description = "Nimi configuraton.";
      };

      recipe = lib.mkOption {
        internal = true;
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Script that builds container image recipe.";
      };

      imageBuilder = lib.mkOption {
        internal = true;
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Script that builds container image.";
      };

      # HACK:
      # Prevent toJSON conversion from attempting to convert the `eval` option,
      # which won't work because it's a whole NixOS evaluation.
      __toString = lib.mkOption {
        internal = true;
        readOnly = true;
        type = with lib.types; functionTo str;
        default = self: "container";
      };
    };
  };

  config = {
    result.nimi.config = {
      settings.container = {
        copyToRoot = config.requirements;
        inherit (config) imageConfig;
      };

      services = lib.mapAttrs (serviceName: service: {
        imports = [
          service
          {
            options.nimi = lib.mkOption {
              type = with lib.types; lazyAttrsOf (attrsOf anything);
              default = { };
              description = ''
                Let the modular service know that it's evaluated for nimi,
                by testing `options ? nimi`.
              '';
            };
          }
        ];
      }) app.services;
    };

    result.nimi.eval = nimi.passthru.evalNimiModule { inherit (config.result.nimi) config; };

    result.recipe = nimi.mkContainerImage { inherit (config.result.nimi) config; };

    result.imageBuilder = pkgs.runCommand "build-oci" { meta.mainProgram = "build-oci"; } ''
      mkdir -p $out/bin

      cat > $out/bin/build-oci <<EOF
      #!${pkgs.runtimeShell}
      ${config.result.recipe.copyTo}/bin/copy-to \
        oci-archive:${config.name}.tar:${config.name}:${config.tag}
      EOF

      chmod +x $out/bin/build-oci

      ${lib.optionalString (config.composeFile != null) ''
        cp ${config.composeFile} $out/compose.yaml
      ''}
    '';
  };
}
