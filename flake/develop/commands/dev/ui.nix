# Usage:
#   nix-shell --run 'dev-ui'
{
  lib,
  which,
  replaceVarsWith,
  runtimeShell,
}:
(replaceVarsWith {
  name = "dev-ui";
  isExecutable = true;
  dir = "bin";
  src = ./ui.sh;
  replacements = { inherit runtimeShell; };
  meta.description = "UI dev script";
})
