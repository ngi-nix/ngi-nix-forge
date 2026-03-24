{
  config,
  lib,

  inputs,
  nimi,
  pkgs,
  system,
  ...
}:
{
  options = {
    # General configuration
    name = lib.mkOption {
      type = lib.types.str;
      default = "my-application";
    };
    description = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    version = lib.mkOption {
      type = lib.types.str;
      default = "1.0.0";
    };
    usage = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Application usage description in markdown format.";
    };

    # NOTE: ideally, this should either:
    # 1. be automatically populated from submodules (services, programs, ...)
    # 2. populate the submodules from this option (attrsOf packages)
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Forge packages used by the application.";
      # TODO: assert that packages are internal to the forge?
    };

    # Portable services configuration
    # https://nixos.org/manual/nixos/unstable/#modular-services
    services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submoduleWith {
          specialArgs = { inherit pkgs inputs; };
          modules = [ ./services ];
        }
      );
      default = { };
      description = "Portable services.";
      # map user-config to a format which can be used by modular services
      apply =
        self:
        lib.mapAttrs (
          _name: value:
          let
            command = if lib.isDerivation value.command then lib.getExe value.command else value.command;
          in
          {
            process.argv = [ command ] ++ value.argv;
            configData = value.configData;
            passthru.raw = value;
          }
        ) self;
    };

    # Programs shell configuration
    programs = lib.mkOption {
      type = lib.types.submodule ./programs;
      default = { };
      description = "Programs shell configuration.";
    };

    # Container configuration
    container = lib.mkOption {
      type = lib.types.submodule {
        imports = [ ./container ];
        _module.args.app = config;
        _module.args.pkgs = pkgs;
        _module.args.nimi = nimi;
      };
      default = { };
      description = "Container configuration.";
    };

    # NixOS/VM configuration
    nixos = lib.mkOption {
      type = lib.types.submodule {
        imports = [ ./nixos ];
        _module.args.app = config;
        _module.args.inputs = inputs;
        _module.args.system = system;
      };
      default = { };
      description = "NixOS system configuration.";
    };
  };

  config = {
    packages =
      let
        service-packages = lib.flatten (
          lib.mapAttrsToList (name: value: value.passthru.raw.command) config.services
        );

        packages = service-packages ++ config.programs.requirements ++ config.container.requirements;
      in
      lib.pipe packages [
        # NOTE: `unique` has an O(n^2) complexity
        # - would that be an issue for our usecase?
        # - could we perhaps do better?
        (lib.unique)
        (map (package: {
          inherit (package)
            pname
            version
            ;
          meta = {
            inherit (package.meta)
              description
              license
              position
              ;
          };
          storePath = package.outPath;
        }))
      ];
  };
}
