{
  lib,
  ...
}:
{
  options = {
    enable = lib.mkEnableOption ''
      Shell output.
    '';
    requirements = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };
}
