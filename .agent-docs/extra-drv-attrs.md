<!-- .agent-docs/extra-drv-attrs.md -->
<!-- Read this file for advanced recipe customization options. -->

# Advanced: extraDrvAttrs

For expert-level customization:

```nix
build.extraDrvAttrs = {
  preConfigure = ''
    export HOME=$(mktemp -d)
  '';
  postInstall = ''
    wrapProgram $out/bin/program \
      --set SOME_VAR value
  '';
  enableParallelBuilding = true;
};
```

**Common use cases**:
- `preConfigure`: Set environment before configure
- `postInstall`: Wrap binaries, add extra files
- `patches`: Apply source patches
- `configureFlags`: Pass flags to configure script
- `cmakeFlags`: Pass flags to CMake
- `mesonFlags`: Pass flags to Meson
- `sourceRoot`: Set when build files are in a subdirectory
