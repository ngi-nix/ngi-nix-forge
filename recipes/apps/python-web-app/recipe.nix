{
  config,
  lib,
  pkgs,
  ...
}:

{
  name = "python-web-app";
  version = "1.0.0";
  description = "Simple web application with database backend.";
  usage = ''
    This is a simple example app which provides a web API to manage a list of
    users.

    * Initialize database
    ```
    curl -X POST localhost:5000/init
    ```

    * Add a new user
    ```
    curl -X POST \
      --header "Content-Type: application/json" \
      --data '{"name":"username"}' \
    localhost:5000/users
    ```

    * Get list of all users
    ```
    curl localhost:5000/users
    ```
  '';

  grants = {
    Entrust = [ "Mox" ];
    Commons = [ "PdfDing" ];
    Core = [ "0WM" ];
    Review = [ "Mox-API" ];
  };

  programs = {
    enable = true;
    requirements = [
      pkgs.curl
    ];
  };

  services.python-web = {
    command = pkgs.mypkgs.python-web;
  };

  container = {
    enable = true;
    name = "python-web";
    requirements = [ pkgs.mypkgs.python-web ];
    # Alternatively, we can re-use attributes with `config`:
    #requirements = [ config.services.python-web.command ];
    composeFile = ./compose.yaml;
  };

  nixos = {
    enable = true;
    name = "python-web";
    extraConfig = {
      # database service
      services.postgresql.enable = true;
      services.postgresql.enableTCPIP = true;
      services.postgresql.authentication = ''
        local all all trust
        host all all 0.0.0.0/0 trust
        host all all ::0/0 trust
      '';
    };
    vm.forwardPorts = [
      "5000:5000"
    ];
  };
}
