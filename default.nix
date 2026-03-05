{
  flake-inputs ? import (fetchTarball {
    url = "https://github.com/fricklerhandwerk/flake-inputs/tarball/4.1.0";
    sha256 = "1j57avx2mqjnhrsgq3xl7ih8v7bdhz1kj3min6364f486ys048bm";
  }),
  flake ? flake-inputs.import-flake { src = ./.; },
  inputs ? flake.inputs,
  system ? builtins.currentSystem,
  pkgs ? import inputs.nixpkgs {
    config = { };
    overlays = [ ];
    inherit system;
  },
  lib ? import "${inputs.nixpkgs}/lib",
}:
let
  default = lib.makeScope pkgs.newScope (def: {
    inherit
      lib
      pkgs
      flake
      system
      inputs
      default # recurse scope
      ;

    nimi-def = import inputs.nimi-def { inherit pkgs; };
    nimi = def.nimi-def.nimi;
    nimiLib = def.nimi.passthru;

    mox = flake.outputs.packages.x86_64-linux.mox;

    app = call ./nimi.nix { inherit (default) nimi mox; };

    debug = eval {
      imports = [
        # ./forge/flake-module.nix
        # ./flake/develop.nix
        # ./flake/checks.nix
        # ./flake/templates.nix

        ./_forge/flake-module.nix
        ./_forge/modules/flake-module.nix
      ];

      _module.args.rootPath = ./.;
      _module.args.inputs = inputs;
      _module.args.flake-parts-lib = inputs.flake-parts.lib;
    };

    output = flake.outputs.allSystems.x86_64-linux;

    apps = default.output.forge.apps;

    forgePkgs = lib.listToAttrs (
      map (v: {
        name = v.name;
        value = v;
      }) default.output.forge.packages
    );
  });

  eval = module: (lib.evalModules { modules = [ module ]; });
  call = default.callPackage;
in
default // flake.outputs.packages.${system}
