{
  config,
  lib,
  pkgs,
  ...
}:

{
  name = "aerogramme";
  version = "0.3.0";
  description = "Encrypted e-mail storage over Garage";
  homePage = "https://aerogramme.deuxfleurs.fr/";
  mainProgram = "aerogramme";
  license = lib.licenses.eupl12;

  source = {
    # path = pkgs.fetchgit {
    #   url = "https://git.deuxfleurs.fr/Deuxfleurs/aerogramme/";
    #   tag = "0.3.0";
    #   hash = "sha256-ER+P/XGqNzTLwDLK5EBZq/Dl29ZZKl2FdxDb+oLEJ8Y=";
    # };
    git = "git:https://git.deuxfleurs.fr/Deuxfleurs/aerogramme:3.0.0";
    hash = "";

    patches = [
      ./0001-update-time-rs.patch
    ];
  };

  build.rustPackageBuilder = {
    enable = true;
    requirements = {
      native = [
        pkgs.pkg-config
      ];
      build = [
        pkgs.openssl
      ];
    };
    cargoHash = "sha256-GPj8qhfKgfAadQD9DJafN4ec8L6oY62PS/w/ljkPHpw=";
  };

  build.extraDrvAttrs = {
    # disable network tests as Nix sandbox breaks them
    doCheck = false;

    env = {
      # get openssl-sys to use pkg-config
      OPENSSL_NO_VENDOR = true;
      RUSTC_BOOTSTRAP = true;
    };
  };

  test.script = ''
    aerogramme --help
  '';
}
