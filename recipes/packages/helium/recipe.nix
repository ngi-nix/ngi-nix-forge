{
  config,
  lib,
  pkgs,
  ...
}:

{
  name = "helium";
  version = "7.0.0";
  description = "Lighter browser automation based on Selenium.";
  homePage = "https://github.com/mherrmann/helium";
  mainProgram = "";
  license = lib.licenses.mit;

  source = {
    git = "github:mherrmann/helium/v7.0.0";
    hash = "sha256-SGLxP2OOzosLpZn/DgIJN3BnbUeg8cXE1HhKBF4EpyM=";
  };

  build.pythonPackageBuilder = {
    enable = true;
    requirements = {
      build-system = [
        pkgs.python3Packages.setuptools
      ];
      dependencies = [
        pkgs.python3Packages.selenium
      ];
    };
  };

  test.script = ''
    python -c "import helium; print('helium imported successfully')"
  '';
}
