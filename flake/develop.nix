{ ... }:
{
  perSystem =
    {
      config,
      lib,
      pkgs,
      self',
      system,
      ...
    }:

    {
      devShells = {
        default = pkgs.mkShellNoCC {
          allowSubstitutes = false;
          packages = with pkgs; [
            elmPackages.elm
            elmPackages.elm-format
            elmPackages.elm-language-server
            elmPackages.elm-review
            elmPackages.elm-test-rs
            esbuild
            json-diff
            nixfmt
            nodejs
            self'.packages.elm-watch
            self'.packages.elm2nix
            systemd-manager-tui
            watchman
          ];
          shellHook = ''
            PATH="$PWD/bin:$PATH"
            {
            echo
            echo "$(tput rev)QuickStart$(tput sgr0): run the ui-dev command"
            echo "to get a development Web server with live reload."
            echo "Interrupt by sending SIGINT with Ctrl-C"
            echo "$(tput rev)Documentation$(tput sgr0): browse docs/manuals/contributor/ for more."
            echo
            }
          '';
        };
      };
    };
}
