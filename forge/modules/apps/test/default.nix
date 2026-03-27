{
  lib,

  app,
  config,
  pkgs,
  ...
}:
{
  options = {
    requirements = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages required for running tests.";
      example = lib.literalExpression "[ pkgs.curl pkgs.jq ]";
    };

    script = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Bash script to run application tests inside a NixOS machine.

        The application's services are available in the machine.
        Run with: nix build .#<app>.test
      '';
      example = lib.literalExpression ''
        '''
        curl -f http://localhost:5000/users
        '''
      '';
    };

    result = {
      build = lib.mkOption {
        internal = true;
        readOnly = true;
        type = lib.types.package;
        description = "NixOS test derivation.";
      };

      # HACK:
      # Prevent toJSON from attempting to convert the `build` option,
      # which won't work because it's a whole NixOS test evaluation.
      __toString = lib.mkOption {
        internal = true;
        readOnly = true;
        type = with lib.types; functionTo str;
        default = self: "nixos-test";
      };
    };
  };

  config = {
    result.build = pkgs.testers.runNixOSTest {
      name = "${app.name}-test";
      nodes.machine = {
        imports = app.nixos.result.modules;
        system.stateVersion = "25.11";
        environment.systemPackages = app.programs.requirements ++ config.requirements;
      };
      testScript = ''
        machine.start()
        machine.wait_for_unit("multi-user.target")
        machine.succeed("${pkgs.writeShellScript "${app.name}-test-script" config.script}")
      '';
    };
  };
}
