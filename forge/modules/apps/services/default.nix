{
  inputs,
  pkgs,

  lib,
  ...
}:
{
  imports = [
    # configData
    (lib.modules.importApply (
      inputs.nixpkgs + "/nixos/modules/system/service/portable/config-data.nix"
    ) { inherit pkgs; })
  ];

  options = {
    command = lib.mkOption {
      type = lib.types.either lib.types.package lib.types.str;
      description = "Main command to use for the service.";
    };

    argv = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      default = [ ];
      description = "List of arguments that will be passed to the main program.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Envrionment variables.";
    };
  };
}
