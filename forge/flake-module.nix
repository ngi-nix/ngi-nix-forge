{ inputs }: # nix-forge's inputs (import-tree, nix-utils)

{ lib, self, ... }:

{
  # Import the core forge modules
  imports = [
    ./modules/forge.nix
    ./modules/apps
    ./modules/packages.nix
    ./packages.nix # Generates _forge-config, _forge-options, _forge-ui
  ];

  config = {
    # Override the inputs argument for submodules with nix-forge's inputs
    # This ensures modules have access to nix-utils and import-tree
    _module.args.inputs = lib.mkForce inputs;

    # Recipe loading logic using nix-forge's bundled dependencies
    perSystem =
      {
        config,
        lib,
        pkgs,
        ...
      }@args:

      let
        # Helper to load recipes from a directory using import-tree
        loadRecipes =
          dir:
          if dir == null then
            [ ]
          else
            let
              # Convert string path to actual path relative to flake root
              # self.outPath gives us the flake root directory
              dirPath = self.outPath + "/${dir}";

              recipeFiles = lib.pipe dirPath [
                # Use bundled import-tree from nix-forge inputs
                (inputs.import-tree.withLib lib).leafs
                # Exclude non-recipe files
                (lib.filter (file: lib.hasSuffix "/recipe.nix" file))
              ];
            in
            recipeFiles;

        # Load package and app recipes from configured directories
        packageRecipes = loadRecipes config.forge.recipeDirs.packages;
        appRecipes = loadRecipes config.forge.recipeDirs.apps;
      in
      {
        forge.packages = packageRecipes;
        forge.apps = appRecipes;
      };
  };
}
