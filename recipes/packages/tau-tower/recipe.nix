{
  config,
  pkgs,
  lib,
  ...
}:

{
  name = "tau-tower";
  version = "0.2.2-beta-unstable-2026-03-14";
  description = "Webradio server - broadcasts audio source to clients";
  homePage = "https://github.com/tau-org/tau-tower";
  mainProgram = "tau-tower";
  license = lib.licenses.eupl12;

  source = {
    git = "github:tau-org/tau-tower/26908437b568c80fc470934948067341e581d43e";
    hash = "sha256-qaui9xWNWuh669kWyTnLGqtuDIKFs4K5Iv3Tti6Befk=";
  };

  build.rustPackageBuilder = {
    enable = true;
    requirements = {
      native = with pkgs; [
        perl
        pkg-config
      ];
    };
    cargoHash = "sha256-5BAL5A78LIgr5G50aU1TXl19qkKiUPPVJn/QogfRMKI=";
  };

  test.script = ''
    tau-tower --version
  '';
}
