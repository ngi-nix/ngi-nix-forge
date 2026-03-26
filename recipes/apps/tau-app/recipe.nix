{
  config,
  pkgs,
  lib,
  ...
}:

rec {
  name = "tau-app";
  version = "0.2.101";
  description = "Web radio streaming system - tau-tower server and tau-radio client";

  usage = ''
    ## Tau Radio Streaming System

    This app provides both the tau-tower server and tau-radio client.

    ### tau-tower (Server)
    Run as a service to broadcast audio to clients:
    - Listens on port 3001 by default
    - Broadcasts on port 3002 by default
    - Configuration: ~/.config/tau/config.toml

    ### tau-radio (Client)
    Capture audio from your device and stream to tau-tower:
    ```
    tau-radio --username <user> --password <pass> --host <server-ip>
    ```

    ### Default Ports
    - Server listen: 3001
    - Broadcast: 3002
  '';

  services.tau-tower = {
    command = pkgs.mypkgs.tau-tower;

    configData."credstore/tau.PASSWORD" = {
      source = "/etc/credstore/tau.PASSWORD";
      path = "tau/PASSWORD";
    };

    configData."tau/tower.toml" = {
      source = "/etc/tau/tower.toml";
      path = "tau/tower.toml";
    };
  };

  programs = {
    enable = true;
    requirements = [
      pkgs.mypkgs.tau-radio
      pkgs.mypkgs.tau-tower
    ];
  };

  container = {
    enable = true;
    name = "tau-tower";
    requirements = [
      pkgs.mypkgs.tau-tower
      pkgs.bash
      pkgs.coreutils
      pkgs.gnused
    ];
    # `tau` expects its config to be under `XDG_CONFIG_HOME/tau`
    imageConfig.WorkingDir = "/tau";
    imageConfig.Env = [ "XDG_CONFIG_HOME=/" ];
    # NOTE:
    # `nimi` links its `configData` in `/tmp/nimi-config-*/` and makes
    # that directory available as `XDG_CONFIG_HOME`, but only for service
    # processes. Since this isn't available to the startup script, we work
    # around this by using the files' `source` instead of `path`.
    startup =
      let
        configFile = services.tau-tower.configData."tau/tower.toml";
        passwordFile = services.tau-tower.configData."credstore/tau.PASSWORD";
      in
      pkgs.writeShellScript "setup" ''
        install -Dm600 "${configFile.source}" /tau/tower.toml
        sed -i "s/@password@/$(cat "${passwordFile.source}")/" /tau/tower.toml
      '';
    composeFile = ./compose.yaml;
  };

  nixos = {
    enable = true;
    name = "tau-tower";
    extraConfig =
      let
        # TODO: get these paths directly from configData
        #
        # So, unlike this recipe file, the module under `extraConfig` will be
        # part of the NixOS system and will have access to its `configData`.
        #
        # However, we can't reference this attribute because `extraConfig`
        # can't be a `function` ({config, ...}:{ }) which isn't convertible to
        # JSON, and we need it to be for `_forge-config`.
        #
        # As such, we have to hardcode them for now.
        configFile = "/etc/system-services/tau-tower/tau/tower.toml";
        passwordFile = "/etc/system-services/tau-tower/credstore/tau.PASSWORD";
      in

      {
        # WARN: !!! Don't use in production !!!
        #
        # This will copy your secrets to the Nix store, which is world-readable.
        #
        # Instead, manually put your secret files in the systemd credentials
        # store (e.g. `/etc/credstore/`, `/run/credstore/`, ...).
        #
        # For more information on this topic, see:
        # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#ImportCredential=GLOB
        environment.etc."credstore/tau.PASSWORD".source = ./password;

        environment.etc."tau/tower.toml".source = ./config.toml;

        systemd.services.tau-tower = {
          description = "Tau Webradio Server";
          serviceConfig = {
            DynamicUser = true;
            User = "tau-tower";
            Group = "tau-tower";
            Restart = "on-failure";
            RestartSec = 5;
            StateDirectory = "tau-tower";
            LoadCredential = [
              "password_file:${passwordFile}"
            ];
          };
          unitConfig = {
            StartLimitBurst = 5;
            StartLimitInterval = 100;
          };
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          environment.XDG_CONFIG_HOME = "/var/lib/tau-tower";
          preStart = ''
            install -Dm600 ${configFile} $XDG_CONFIG_HOME/tau/tower.toml
            sed -i "s/@password@/$(cat $CREDENTIALS_DIRECTORY/password_file)/" $XDG_CONFIG_HOME/tau/tower.toml
          '';
          postStop = ''
            rm -f $XDG_CONFIG_HOME/tau/tower.toml
          '';
        };

        environment.systemPackages = [
          pkgs.mypkgs.tau-radio
          pkgs.mypkgs.tau-tower
        ];
      };
    vm.forwardPorts = [
      "3001:3001"
      "3002:3002"
    ];
  };
}
