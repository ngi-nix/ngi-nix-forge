<!-- .agent-docs/dev-environment.md -->
<!-- Read this file when setting up development environments for recipes. -->

# Development Environment

```nix
development = {
  requirements = [ pkgs.gdb pkgs.valgrind ];  # Dev tools
  shellHook = ''
    echo "Development environment ready"
    echo "Source code: clone from ${source.git}"
  '';
};
```
