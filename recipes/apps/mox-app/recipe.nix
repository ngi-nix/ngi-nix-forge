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
    Mox is a modern, full-featured, open source secure mail server providing
    SMTP, IMAP4, webmail, SPF/DKIM/DMARC, and more.

    ## Quick Start

    Run the quickstart to generate configuration:

    ```
    mox quickstart -hostname mail.example.com admin@example.com
    ```

    Output is written to `quickstart.log`, including initial admin
    accounts and passwords. Follow the printed instructions to configure
    DNS records.

    ## Running

    Start the server:

    ```
    mox serve
    ```

    ## Administration

    Access the admin web interface at `http://localhost:8080`.

    Common commands:

    ```
    mox version          # Show version
    mox config example   # Show example SMTP config
    mox help             # Show available commands
    ```
  '';

  programs = {
    enable = true;
    requirements = [
      pkgs.mypkgs.mox
    ];
  };

  services.mox = {
    command = pkgs.mypkgs.mox;
    argv = [
      "-config"
      "/var/lib/mox/config/mox.conf"
      "serve"
    ];
  };

  container = {
    enable = true;
    name = "mox";
    tag = "latest";
    requirements = [ pkgs.mypkgs.mox ];
    composeFile = ./compose.yaml;
  };

  nixos = {
    enable = true;
    name = "mox";
    extraConfig = {
      users.users.mox = {
        isSystemUser = true;
        group = "mox";
        home = "/var/lib/mox";
        createHome = true;
        description = "Mox Mail Server User";
      };
      users.groups.mox = { };

      systemd.services.mox-setup = {
        description = "Mox Quickstart Setup";
        wantedBy = [ "multi-user.target" ];
        requires = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          WorkingDirectory = "/var/lib/mox";
          Type = "oneshot";
          RemainAfterExit = true;
          User = "mox";
          Group = "mox";
          ExecStart = "${pkgs.mypkgs.mox}/bin/mox quickstart -hostname mail.example.com admin@example.com";
        };
      };

      networking.firewall.allowedTCPPorts = [
        25
        80
        443
        465
        587
        993
      ];
      networking.firewall.allowedUDPPorts = [ 53 ];
    };
    vm.forwardPorts = [
      "25:25"
      "80:80"
      "443:443"
      "993:993"
    ];
  };
}
