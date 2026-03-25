{
  description = "NGI Forge";

  nixConfig = {
    extra-substituters = [ "" ];
    extra-trusted-public-keys = [ "" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elm2nix = {
      url = "github:dwayne/elm2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-utils = {
      url = "github:imincik/nix-utils";
      flake = false;
    };

    nimi.url = "github:weyl-ai/nimi";
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
            repositoryUrl = "github:ngi-nix/forge";
            recipeDirs = {
              packages = "recipes/packages";
              apps = "recipes/apps";
            };
          };
        };
    };
}
