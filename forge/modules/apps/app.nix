{
  lib,
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

    # Programs shell configuration
    programs = {
      enable = lib.mkEnableOption ''
        Programs bundle output.
      '';
      requirements = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
    };

    # Container configuration
    containers = lib.mkOption {
      type = lib.types.submodule {
        imports = [ ./containers ];
      };
      default = { };
      description = "Container configuration.";
    };

    # Virtual machine
    vm = lib.mkOption {
      type = lib.types.submodule {
        imports = [ ./vm ];
      };
      default = { };
      description = "NixOS VM configuration.";
    };
  };
}
