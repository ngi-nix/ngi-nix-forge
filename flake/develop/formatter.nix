{
  lib,
  pkgs,
  inputs,
  ...
}:
lib.makeExtensible (self: {
  treefmt = import inputs.treefmt-nix;

  config = {
    projectRootFile = "flake.nix";

    programs.actionlint.enable = true;
    programs.elm-format.enable = true;
    programs.nixfmt.enable = true;
    programs.shfmt.enable = true;

    settings.formatter.editorconfig-checker = {
      command = pkgs.editorconfig-checker;
      includes = [ "*" ];
      priority = 9; # last
    };
  };

  # useful for debugging
  eval = self.treefmt.evalModule pkgs self.config;

  # treefmt package
  package = self.eval.config.build.wrapper;

  # development shell (contains all formatters)
  shell = self.eval.config.build.devShell;
})
