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
    git = "https://git.deuxfleurs.fr/Deuxfleurs/aerogramme";
    tag = "3.0.0";
    hash = "sha256-36/oFUHMyCp1ryqxXI1xg90PL6Gkvk4AtWSoxnvKXiM=";

    # patches = [
    #   ./0001-update-time-rs.patch
    # ];
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
    cargoHash = "sha256-Uro9AqOtNt+oO/u4LYAIZWzSTtc9dr8tgRe6fkjIMrM=";
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
