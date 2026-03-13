{
  description = "Nix Forge";

  nixConfig = {
    extra-substituters = [ "https://flake-forge.cachix.org" ];
    extra-trusted-public-keys = [
      "flake-forge.cachix.org-1:cu8to1JK8J70jntSwC0Z2Uzu6DpwgcWTS3xiiye3Lyw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    elm2nix = {
      url = "github:dwayne/elm2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-utils = {
      url = "github:imincik/nix-utils";
      flake = false;
    };

    nimi.url = "github:weyl-ai/nimi";

    # git-hooks = {
    #   url = "github:cachix/git-hooks.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:

    flake-parts.lib.mkFlake { inherit inputs; } {
      # Uncomment this to enable flake-parts debug.
      # https://flake.parts/options/flake-parts.html?highlight=debug#opt-debug
      # debug = true;

      systems = [
        "x86_64-linux"
        # "aarch64-linux"
        # "aarch64-darwin"
        # "x86_64-darwin"
      ];

      imports = [
        (import ./forge/flake-module.nix { inherit inputs; })
        ./flake/develop.nix
        ./flake/packages.nix
        ./flake/checks.nix
        ./flake/templates.nix
      ];

      _module.args.rootPath = ./.;

      # Export flake module for use in other projects
      flake.flakeModules.default = import ./forge/flake-module.nix { inherit inputs; };

      perSystem =
        { system, ... }:
        {
          _module.args.nimi = inputs.nimi.packages.${system}.nimi;

          forge = {
            repositoryUrl = "github:ngi-nix/ngi-nix-forge";
            recipeDirs = {
              packages = "recipes/packages";
              apps = "recipes/apps";
            };
          };
        };
    };
}
