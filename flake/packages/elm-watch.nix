{
  elmPackages,
  fetchFromGitHub,
  fetchNpmDeps,
  jq,
  lib,
  makeBinaryWrapper,
  nix-update-script,
  nodejs,
  npmHooks,
  runCommand,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "elm-watch";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "lydell";
    repo = "elm-watch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IntRKhilGgnEC+wXKp3l3373TqU3rBPcVWFEzd27KHI=";
  };

  postPatch = ''
    cp -f ${finalAttrs.patchedPackageJSON} package.json
  '';

  patchedPackageJSON =
    runCommand "package.json"
      {
        nativeBuildInputs = [ jq ];
      }
      ''
        jq '
          # Tries to install elm, but this package provisions in PATH
          del(.scripts.postinstall) |
          # Has no version, but npm requires it
          .version = "${finalAttrs.version}"
        ' ${finalAttrs.src}/package.json > $out
      '';

  npmBuildScript = "build";
  npmDepsHash = "sha256-ae4bUl5/GGAtYR7cc8om3C4/XjCUe8v3sWpIhIXBGV8=";
  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = finalAttrs.npmDepsHash;
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    nodejs
    npmHooks.npmConfigHook
    npmHooks.npmBuildHook
    npmHooks.npmInstallHook
  ];

  postInstall = ''
    cp -r build $out/lib/node_modules/build/
    makeWrapper ${lib.getExe nodejs} $out/bin/elm-watch \
      --inherit-argv0 \
      --suffix PATH : ${lib.makeBinPath [ elmPackages.elm ]} \
      --add-flags $out/lib/node_modules/build/build/index.js
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    changelog = "https://github.com/lydell/elm-watch/releases/tag/${finalAttrs.version}";
    description = "`elm make` in watch mode. Fast and reliable";
    homepage = "https://lydell.github.io/elm-watch/";
    license = lib.licenses.mit;
    mainProgram = "elm-watch";
    maintainers = with lib.maintainers; [ julm ];
  };
})
