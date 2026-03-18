{
  config,
  lib,
  pkgs,
  ...
}:

{
  name = "mox-app";
  version = "0.0.15";
  description = "Modern full-featured open source secure mail server for low-maintenance self-hosted email.";
  usage = ''
    Mox is a self-hosted email server providing SMTP, IMAP, and a web admin interface.

    * Check mox version
    ```
      mox version
    ```

    * Access the web admin interface at https://localhost:443/admin/

    * Default credentials are generated during setup (check VM logs)

    ## VM Usage

    The VM is pre-configured with:
    - Unbound as a local DNS resolver
    - A `mox` system user
    - Automatic `mox quickstart` setup for `admin@example.com`
    - SMTP (port 25), Submission (port 587), IMAP (port 143/993), HTTP/HTTPS (port 80/443)
  '';

  services.mox = {
    command = pkgs.mypkgs.mox;
    argv = [
      "-config"
      "/var/lib/mox/config/mox.conf"
      "serve"
    ];
  };

  programs = {
    enable = true;
    requirements = [
      pkgs.mypkgs.mox
    ];
  };

  container = {
    enable = true;
    name = "mox";
    tag = "latest";
    requirements = [ pkgs.mypkgs.mox ];
  };

  nixos = {
    enable = true;
    name = "mox";

    extraConfig = {
      users.users.mox = {
        isSystemUser = true;
        name = "mox";
        group = "mox";
        home = "/var/lib/mox";
        createHome = true;
        description = "Mox Mail Server User";
      };
      users.groups.mox = { };

      environment.systemPackages = [
        pkgs.mypkgs.mox
        pkgs.unbound
      ];

      environment.etc."resolv.conf".text = ''
        nameserver 127.0.0.1
      '';

      networking.nameservers = [ "127.0.0.1" ];
      networking.hosts = {
        "127.0.0.1" = [
          "com."
          "mail.example.com"
          "example.com"
        ];
      };

      services.unbound = {
        enable = true;
        resolveLocalQueries = true;
        enableRootTrustAnchor = false;
        settings = {
          server = {
            interface = [ "127.0.0.1" ];
            access-control = [
              "127.0.0.1/8 allow"
              "::1/128 allow"
            ];
          };
          local-zone = [
            ''"com." redirect''
          ];
          local-data = [
            ''"com. IN NS localhost"''
            ''"localhost. IN A 127.0.0.1"''
          ];
        };
      };

      systemd.services.mox-setup = {
        description = "Mox Setup";
        wantedBy = [ "multi-user.target" ];
        requires = [
          "network-online.target"
          "unbound.service"
        ];
        after = [
          "network-online.target"
          "unbound.service"
        ];
        before = [ "mox.service" ];
        serviceConfig = {
          WorkingDirectory = "/var/lib/mox";
          Type = "oneshot";
          RemainAfterExit = true;
          User = "mox";
          Group = "mox";
          ExecStart = "${lib.getExe pkgs.mypkgs.mox} quickstart -hostname mail admin@example.com";
        };
      };

      systemd.services.mox = {
        after = [ "mox-setup.service" ];
        requires = [ "mox-setup.service" ];
        serviceConfig = {
          WorkingDirectory = "/var/lib/mox";
          Restart = "always";
        };
      };
    };

    vm.forwardPorts = [
      "2525:25"
      "8587:587"
      "8143:143"
      "8993:993"
      "8080:80"
      "8443:443"
    ];
  };
}
