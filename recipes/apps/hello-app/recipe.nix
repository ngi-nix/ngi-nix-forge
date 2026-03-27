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

  programs = {
    enable = true;
    requirements = [
      pkgs.mypkgs.hello
    ];
  };

  services.greet = {
    command = pkgs.mypkgs.hello;
    argv = [
      "--greeting"
      "$GREETING"
    ];
    environment = [ "GREETING=Hello, how are you ?" ];
  };

  container = {
    enable = true;
    name = "hello";
    tag = "latest";
    requirements = [ pkgs.mypkgs.hello ];
    # Alternatively, we can re-use attributes with `config`:
    #requirements = [ config.services.greet.command ];
    imageConfig.Env = [ "GREETING=Hola, cómo estás?" ];
    composeFile = ./compose.yaml;
  };
}
