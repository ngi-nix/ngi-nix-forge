{ inputs, ... }:
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
      formatter = (pkgs.callPackage ./formatter.nix { inherit inputs; }).package;

      devShells = {
        default = pkgs.mkShellNoCC {
          allowSubstitutes = false;
          packages = with pkgs; [
            elmPackages.elm
            elmPackages.elm-format
            elmPackages.elm-language-server
            elmPackages.elm-review
            elmPackages.elm-test
            elmPackages.elm-test-rs
            esbuild
            json-diff
            nixfmt
            nodejs
            self'.packages.elm-watch
            self'.packages.elm2nix
            systemd-manager-tui
            watchman
            podman-compose
          ];
          shellHook = ''
            PATH="$PWD/bin:$PATH"
            {
            echo
            echo "Run"
            echo
            echo "  \$ dev-ui"
            echo
            echo "command to get a development web server with live reload."
            echo "Interrupt by sending SIGINT with Ctrl-C."
            echo
            echo "Browse docs/manuals/contributor/ for more information."
            echo
            }
          '';
        };
      };
    };
}
