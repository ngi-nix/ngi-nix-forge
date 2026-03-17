{
  config,
  pkgs,
  lib,
  ...
}:

{
  name = "hello-app";
  version = "1.0.0";
  description = "Say hello in multiple languages.";

  services.greet = {
    command = pkgs.mypkgs.hello;
    argv = [
      "--greeting"
      "$GREETING"
    ];
    environment = [ "GREETING=Hello, how are you ?" ];
  };

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
    requirements = [ pkgs.mypkgs.hello ];
    imageConfig.Env = [ "GREETING=Hola, cómo estás?" ];
    composeFile = ./compose.yaml;
  };
}
