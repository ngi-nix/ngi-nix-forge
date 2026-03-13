{
  config,
  lib,
  pkgs,
  ...
}:

{
  name = "hello-app";
  version = "1.0.0";
  description = "Say hello to Nix.";

  programs = {
    enable = true;
    requirements = [
      pkgs.mypkgs.hello-nix
    ];
  };

  container = {
    enable = true;
    name = "hello";
    requirements = [ pkgs.mypkgs.hello-nix ];
    imageConfig.CMD = [
      "hello"
    ];
    composeFile = ./compose.yaml;
  };

  nixos = {
    enable = true;
    name = "hello";
    extraConfig = {
      environment.systemPackages = [
        pkgs.mypkgs.hello-nix
      ];
    };
  };
}
