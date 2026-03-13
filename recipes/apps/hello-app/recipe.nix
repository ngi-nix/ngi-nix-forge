{
  config,
  lib,
  pkgs,
  ...
}:

{
  name = "hello-app";
  version = "1.0.0";
  description = "Say hello in multiple languages.";

  programs = {
    enable = true;
    requirements = [
      pkgs.mypkgs.hello
    ];
  };

  container = {
    enable = true;
    name = "hello";
    tag = "latest";
    imageConfig = {
      Env = [
        "flag=yes"
      ];
    };
    requirements = [
      pkgs.mypkgs.hello
    ];
    composeFile = ./compose.yaml;
  };
}
