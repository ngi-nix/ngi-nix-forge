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
    containers = {
      enable = lib.mkEnableOption ''
        Container images output.
      '';
      images = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                default = "app-container";
              };
              requirements = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [ ];
              };
              config = {
                CMD = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                };
              };
            };
          }
        );
        default = [ ];
        description = "List of container images to build.";
        example = lib.literalExpression ''
          [
            {
              name = "api";
              requirements = [ mypkgs.my-package ];
              config.CMD = [ "my-command" ];
            }
          ]
        '';
      };
      composeFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Relative path to a container compose file.";
        example = "./compose.yaml";
      };
    };

    # Virtual machine
    vm = {
      enable = lib.mkEnableOption ''
        Virtual machine.
      '';
      name = lib.mkOption {
        type = lib.types.str;
        default = "nixos-vm";
      };
      requirements = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
      config = {
        system = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = ''
            NixOS system configuration.

            See: https://search.nixos.org/options
          '';
          example = lib.literalExpression ''
            {
              services.postgresql.enabled = true;
            }
          '';
        };
        ports = lib.mkOption {
          type = lib.types.listOf (lib.types.strMatching "^[0-9]*:[0-9]*$");
          default = [ ];
          description = ''
            List of ports to forward from host system to VM.

            Format: HOST_PORT:VM_PORT
          '';
          example = lib.literalExpression ''
            [ "10022:22" "5432:5432" "8000:90" ]
          '';
        };
        cores = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Number of CPU cores available to VM.";
          example = 8;
        };
        memorySize = lib.mkOption {
          type = lib.types.int;
          default = 1024 * 2;
          description = "VM memory size in MB.";
          example = 1024 * 4;
        };
        diskSize = lib.mkOption {
          type = lib.types.int;
          default = 1024 * 4;
          description = "VM disk size in MB.";
          example = 1024 * 10;
        };
      };
    };
  };
}
