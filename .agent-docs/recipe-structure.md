<!-- .agent-docs/recipe-structure.md -->
<!-- Read this file to understand recipe file locations, the basic template, and how to reference other Nix Forge packages. -->

# Recipe File Structure

## Location

- **Packages**: `recipes/packages/<package-name>/recipe.nix`
- **Apps**: `recipes/apps/<app-name>/recipe.nix`

## Basic Template

```nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Recipe fields go here
}
```

**Note**: The function parameters are REQUIRED and should always be included, even if not used.

## Accessing Nix Forge Packages

Other packages built by Nix Forge can be referenced in recipes using `pkgs.mypkgs`:

```nix
{
  # Reference another Nix Forge package
  requirements.build = [
    pkgs.mypkgs.gdal  # Access gdal from Nix Forge
  ];
}
```

This follows the same pattern as accessing nixpkgs packages (e.g., `pkgs.sqlite`).

## Important: Git Tracking Required

**CRITICAL**: All new recipe files MUST be added to git before they can be used by the Nix flake system.

After creating a new recipe file, you must run:
```bash
git add recipes/packages/<package-name>/recipe.nix
# or for apps:
git add recipes/apps/<app-name>/recipe.nix
```

The flake uses `import-tree` to automatically discover recipes, but it only sees files tracked by git. Without adding the file to git, the package will not be recognized and `nix build .#<package-name>` will fail with an error like:
```
error: flake does not provide attribute 'packages.x86_64-linux.<package-name>'
```
