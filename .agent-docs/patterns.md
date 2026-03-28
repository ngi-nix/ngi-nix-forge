<!-- .agent-docs/patterns.md -->
<!-- Read this file for common recipe patterns and templates. -->

# Common Patterns

## Pattern 1: Simple GitHub Project

```nix
{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:

{
  name = "ripgrep";
  version = "14.0.0";
  description = "Fast line-oriented search tool.";
  homePage = "https://github.com/BurntSushi/ripgrep";
  mainProgram = "rg";

  source = {
    git = "github:BurntSushi/ripgrep/14.0.0";
    hash = "sha256-...";
  };

  build.standardBuilder = {
    enable = true;
    requirements.native = [
      pkgs.rustc
      pkgs.cargo
    ];
    requirements.build = [ ];
  };

  test.script = ''
    rg --version | grep "14.0.0"
  '';
}
```

---

## Pattern 2: C Project with Dependencies

```nix
{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:

{
  name = "nginx";
  version = "1.24.0";
  description = "HTTP and reverse proxy server.";
  homePage = "https://nginx.org";
  mainProgram = "nginx";

  source = {
    url = "https://nginx.org/download/nginx-1.24.0.tar.gz";
    hash = "sha256-...";
  };

  build.standardBuilder = {
    enable = true;
    requirements.native = [
      pkgs.which
    ];
    requirements.build = [
      pkgs.openssl
      pkgs.pcre
      pkgs.zlib
    ];
  };

  test.script = ''
    nginx -v 2>&1 | grep "1.24.0"
  '';
}
```

---

## Pattern 3: Python Application

```nix
{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:

{
  name = "mypy";
  version = "1.7.0";
  description = "Static type checker for Python.";
  homePage = "https://mypy-lang.org";
  mainProgram = "mypy";

  source = {
    git = "github:python/mypy/v1.7.0";
    hash = "sha256-...";
  };

  build.pythonAppBuilder = {
    enable = true;
    requirements.build-system = [
      pkgs.python3Packages.setuptools
    ];
    requirements.dependencies = [
      pkgs.python3Packages.typing-extensions
      pkgs.python3Packages.mypy-extensions
    ];
  };

  test.script = ''
    mypy --version | grep "1.7.0"
  '';
}
```

---

## Pattern 4: Python Library

```nix
{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:

{
  name = "requests";
  version = "2.31.0";
  description = "Python HTTP library for humans.";
  homePage = "https://requests.readthedocs.io";
  mainProgram = "";  # No main program for libraries

  source = {
    git = "github:psf/requests/v2.31.0";
    hash = "sha256-...";
  };

  build.pythonPackageBuilder = {
    enable = true;
    requirements.build-system = [
      pkgs.python3Packages.setuptools
    ];
    requirements.dependencies = [
      pkgs.python3Packages.charset-normalizer
      pkgs.python3Packages.idna
      pkgs.python3Packages.urllib3
      pkgs.python3Packages.certifi
    ];
  };

  test.script = ''
    python -c "import requests; print(requests.__version__)" | grep "2.31.0"
  '';
}
```
