{
  buildElmApplication,
  fetchzip,
  symlinkJoin,

  _forge-config,
  _forge-options,
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

  options = buildElmApplication {
    pname = "forge-ui-options";
    version = "0.1.0";
    src = ./.;
    elmLock = ./elm.lock;
    entry = [ "src/OptionsMain.elm" ];
    output = "options.js";
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
    options
  ];
  postBuild = ''
    # Copy static files
    cp ${./src/index.html} $out/index.html
    cp ${./src/options.html} $out/options.html
    mkdir -p $out/resources
    chmod -R u+w $out/resources
    cp ${bootstrapCss}/css/bootstrap.min.css $out/resources/bootstrap.min.css
    cp ${agentsFile} $out/resources/AGENTS.md

    # Symlink config files
    ln -s ${_forge-config} $out/forge-config.json
    ln -s ${_forge-options} $out/options.json

    # Rename minimized Elm outputs
    mv $out/main.min.js $out/main.js
    mv $out/options.min.js $out/options.js
  '';
  passthru = { inherit bootstrapCss; };
}
