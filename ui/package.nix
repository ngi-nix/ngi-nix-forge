{
  buildElmApplication,
  fetchzip,
  jq,
  symlinkJoin,

  _forge-config,
  ...
}:

let
  main = buildElmApplication {
    pname = "forge-ui-elm";
    version = "0.1.0";
    src = ./.;
    elmLock = ./elm.lock;
    entry = [ "src/Main.elm" ];
    output = "main.js";
    doMinification = true;
    enableOptimizations = true;
  };

  agentsFile = ../AGENTS.md;

  bootstrapCss = fetchzip rec {
    pname = "bootstrap";
    version = "5.3.8";
    url = "https://github.com/twbs/bootstrap/releases/download/v${version}/bootstrap-${version}-dist.zip";
    hash = "sha256-StRhHJIRGzguLlo0BGOAMy0PCCmMovzgU/5xZJgVrqQ=";
  };
in
symlinkJoin {
  name = "forge-ui";
  paths = [
    main
  ];
  postBuild = ''
    pushd $out

    # Copy static files
    cp ${./src/index.html} index.html
    mkdir -p resources
    chmod -R u+w resources
    cp ${bootstrapCss}/css/bootstrap.min.css resources/bootstrap.min.css
    cp ${agentsFile} resources/AGENTS.md

    # Symlink config files
    ln -s ${_forge-config} forge-config.json

    # Rename minimized Elm outputs
    mv main.min.js main.js
    ln -s main.js Elm.js

    # github pages SPA workaround for routing
    for app in $(${jq}/bin/jq '.apps.[].name' -r forge-config.json); do
      mkdir -p "app/$app"
      ln -s $out/index.html "app/$app/index.html"
    done

    popd
  '';
  passthru = { inherit bootstrapCss; };
}
