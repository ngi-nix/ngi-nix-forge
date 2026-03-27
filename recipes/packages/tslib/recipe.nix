{
  config,
  lib,
  pkgs,
  ...
}:

rec {
  name = "tslib";
  version = "1.24";
  description = "Touchscreen access library";
  homePage = "http://www.tslib.org/";
  mainProgram = "";
  license = lib.licenses.lgpl21;

  source = {
    git = "github:libts/tslib/${version}";
    hash = "sha256-WrzOTZlceYnFXi5AI5vb+ZDSRoqUDk/yyCdBUWKn0sM=";
  };

  build.standardBuilder = {
    enable = true;
    requirements.native = [
      pkgs.cmake
    ];
  };
}
