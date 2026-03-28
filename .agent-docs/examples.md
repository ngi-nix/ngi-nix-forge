<!-- .agent-docs/examples.md -->
<!-- Read this file for detailed annotated examples of complex recipes. -->

# Annotated Examples

## Example 1: Complex Project (geodiff)

This example demonstrates a complex CMake project with subdirectory structure:

```nix
{ config, lib, pkgs, mypkgs, ... }:

{
  name = "geodiff";
  version = "2.0.4";
  description = "Library for handling diffs for geospatial data (GeoPackage and PostGIS).";
  homePage = "https://merginmaps.com";
  mainProgram = "geodiff";

  source = {
    git = "github:MerginMaps/geodiff/2.0.4";
    hash = "sha256-STWoSnBDl3K3F9SeXGvTy8TzZSAP6rZh3ebfMqdT/w0=";
    # Note: Current implementation does not fetch git submodules
  };

  build.standardBuilder = {
    enable = true;
    requirements = {
      # Build tools needed during compilation
      native = [
        pkgs.cmake        # CMake build system
        pkgs.pkg-config   # For finding SQLite
      ];
      # Libraries needed at runtime
      build = [
        pkgs.sqlite       # Required dependency
      ];
    };
  };

  build.extraDrvAttrs = {
    # CMakeLists.txt is in geodiff/geodiff/, not the root directory
    # Repository structure: geodiff/geodiff/CMakeLists.txt
    sourceRoot = "source/geodiff";

    # Optional: Override CMake configuration flags
    # cmakeFlags = [ "-DWITH_POSTGRESQL=OFF" ];

    # Optional: Disable tests if they fail or slow down
    # cmakeFlags = [ "-DENABLE_TESTS=OFF" ];
  };

  test.script = ''
    # Minimum viable tests
    geodiff --help
    geodiff --version
  '';
}
```

**Key points in this example:**

1. **sourceRoot**: Required because CMakeLists.txt is in `geodiff/` subdirectory
2. **cmake and pkg-config**: In `native` because they're build-time tools
3. **sqlite**: In `build` because it's a runtime dependency
4. **Test script**: Simple verification that the binary works

---

## Example 2: Python Project (fiona)

This example demonstrates a Python project with complex dependencies:

```nix
{ config, lib, pkgs, mypkgs, ... }:

{
  name = "fiona";
  version = "1.10.1";
  description = "Python library for reading and writing vector geospatial data files.";
  homePage = "https://fiona.readthedocs.io";
  mainProgram = "fio";

  source = {
    git = "github:Toblerity/Fiona/1.10.1";
    hash = "sha256-5NN6PBh+6HS9OCc9eC2TcBvkcwtI4DV8qXnz4tlaMXc=";
  };

  build.pythonAppBuilder = {
    enable = true;
    requirements = {
      # Python build system packages
      build-system = [
        pkgs.python3Packages.setuptools
        pkgs.python3Packages.cython
        pkgs.gdal  # GDAL also needed at build time for gdal-config
      ];
      # Python runtime dependencies
      dependencies = [
        pkgs.python3Packages.attrs
        pkgs.python3Packages.certifi
        pkgs.python3Packages.click
        pkgs.python3Packages.click-plugins
        pkgs.python3Packages.cligj
        pkgs.python3Packages.cython
        pkgs.gdal  # GDAL needed at runtime
      ];
    };
  };

  build.extraDrvAttrs = {
    # Relax Cython version constraint from ~=3.0.2 to accept any version
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail "cython~=3.0.2" cython
    '';
  };

  test.script = ''
    # Test both Python import and CLI tool
    python -c "import fiona; print(fiona.__version__)"
    fio --version
  '';
}
```

**Key points in this example:**

1. **pythonAppBuilder**: Used for Python applications with CLI tools (fio command)
2. **GDAL in both build-system and dependencies**: Needed at build time (for `gdal-config`) and runtime
3. **postPatch**: Relaxes strict version constraint that would otherwise fail
4. **Test script**: Tests both the Python module import and CLI tool

**Note**: If this were a library without the `fio` CLI tool, use `pythonPackageBuilder` instead.
