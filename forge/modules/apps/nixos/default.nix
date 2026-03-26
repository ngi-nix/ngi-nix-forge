{
  lib,
  inputs,

  app,
  config,
  system,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption "NixOS/VM output";

    name = lib.mkOption {
      type = lib.types.str;
      default = "nixos-vm";
      description = "Hostname for the VM.";
    };

    # TODO:
    # - wire this up with nimi
    # - maybe rename to `nimi` or `nimi-settings`?
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Nimi settings for the NixOS configuration.";
      example = lib.literalExpression ''
        {
          restart.mode = "always";
          restart.time = 1000;
          logging.enable = true;
        }
      '';
    };

    extraConfig = lib.mkOption {
      type = with lib.types; lazyAttrsOf (either attrs anything);
      default = { };
      description = ''
        NixOS system configuration

        See: https://search.nixos.org/options
      '';
      example = lib.literalExpression ''
        {
          services.postgresql.enable = true;
        }
      '';
    };

    vm = {
      cores = lib.mkOption {
        type = lib.types.int;
        default = 4;
        description = "Number of CPU cores available to VM.";
        example = 8;
      };
      diskSize = lib.mkOption {
        type = lib.types.int;
        default = 1024 * 4;
        description = "VM disk size in MiB.";
        example = 1024 * 10;
      };
      memorySize = lib.mkOption {
        type = lib.types.int;
        default = 1024 * 2;
        description = "VM memory size in MiB.";
        example = 1024 * 4;
      };
      forwardPorts = lib.mkOption {
        type = lib.types.listOf (lib.types.strMatching "^[0-9]*:[0-9]*$");
        default = [ ];
        description = ''
          List of ports to forward from host system to VM.

          Format: HOST_PORT:VM_PORT
        '';
        example = lib.literalExpression ''
          [ "10022:22" "5432:5432" "8000:80" ]
        '';
        apply =
          self:
          map (
            portRange:
            let
              portSplit = lib.splitString ":" portRange;
            in
            {
              from = "host";
              host.port = lib.toInt (lib.elemAt portSplit 0);
              guest.port = lib.toInt (lib.elemAt portSplit 1);
            }
          ) self;
      };
    };

    result = {
      eval = lib.mkOption {
        internal = true;
        readOnly = true;
        type = with lib.types; lazyAttrsOf (either attrs anything);
        description = "NixOS system evaluation.";
      };

      build = lib.mkOption {
        internal = true;
        readOnly = true;
        type = lib.types.package;
        default = config.result.eval.config.system.build.vm;
        description = "NixOS Virtual Machine.";
      };

      # HACK:
      # Prevent toJSON from attempting to convert the `eval` option,
      # which won't work because it's a whole NixOS evaluation.
      __toString = lib.mkOption {
        internal = true;
        readOnly = true;
        type = with lib.types; functionTo str;
        default = self: "nixos-vm-config";
      };
    };
  };

  config = {
    result.eval = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        (
          { modulesPath, ... }:
          {
            imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

            virtualisation = {
              graphics = false;

              inherit (config.vm)
                cores
                diskSize
                forwardPorts
                memorySize
                ;
            };
          }
        )
        {
          users.users.root.password = "root";

          services = {
            openssh.settings.PermitRootLogin = lib.mkForce "yes";
            openssh.settings.PasswordAuthentication = lib.mkForce true;
            getty.autologinUser = "root";
          };

          networking = {
            hostName = config.name;
            useDHCP = lib.mkForce true;
            firewall.enable = lib.mkForce false;
          };

          system.stateVersion = "25.11";
        }
        {
          # modular services
          system = {
            services = lib.pipe app.services [
              # NixOS already defines `configData."*".path`, but other runtimes
              # don't do that. Since it's a read-only option, we can't just
              # change its priority, so here we just filter out any non-NixOS
              # declarations of that option.
              # TODO: is there a more robust way of doing this?
              # configData."*".path -> remove
              (lib.filterAttrsRecursive (name: value: name != "path"))
              # pass env vars to systemd; escape args
              (lib.mapAttrs (
                name: value:
                lib.recursiveUpdate (lib.removeAttrs value [ "passthru" ]) {
                  systemd.mainExecStart = lib.escapeShellArgs value.process.argv;
                  systemd.service.environment = value.passthru.raw.environment;
                }
              ))
            ];
          };

          environment.variables = lib.concatMapAttrs (_: value: value.passthru.raw.environment) app.services;
        }
        config.extraConfig
      ];
    };
  };
}
