#!/usr/bin/env bash
set -u
rootDir="$(git rev-parse --show-toplevel)"
cd "$rootDir"
listenPort="${listenPort:-3000}"
unit=ngi_nix_dev-"$listenPort"
slice=session-"$unit"
function clean {
  set +e
  systemctl --user stop "$slice".slice
  rm -f /run/user/"$UID"/systemd/user/"$unit"-*
  rm -rf "$rootDir"/ui/build
}
function onExit {
  set +e
  clean
  watchman trigger-del . "$unit"-backend
  watchman watch-del .
}

trap onExit EXIT
clean
set -ex

mkdir -p "$rootDir/ui/build/js"

# copy the favicon to build
ln -s "$rootDir/ui/src/favicon.svg" "$rootDir/ui/build/favicon.svg"

# Warning(correctness): when using `nix build`,
# be careful to either register the resulting output(s)
# in $rootDir/ui/build as roots to nix's garbage-collector (GC)
# by using `-o`, or to copy files out of the Nix store.
# Otherwise the GC can remove the results at any moment.

systemctl --user edit --runtime --force --full "$unit"-backend.service --stdin <<EOT
[Unit]

[Service]
Type=oneshot
RemainAfterExit=yes
Slice=$slice.slice
ExecStart=$(command -v nix) build -f "$rootDir" _forge-ui.passthru.bootstrapCss -o "$rootDir/ui/build/bootstrap" --show-trace
ExecStart=$(command -v nix) build -f "$rootDir" _forge-config -o "$rootDir/ui/build/forge-config.json" --show-trace
ExecStart=$(command -v nix) build -f "$rootDir" _forge-options -o "$rootDir/ui/build/forge-options.json" --show-trace
EOT

systemctl --user edit --runtime --force --full "$unit"-elm-watch.service --stdin <<EOT
[Unit]
After=$unit-backend.service
Wants=$unit-backend.service

[Service]
Type=simple
Slice=$slice.slice
WorkingDirectory=$rootDir/ui
Environment=ELM_WATCH_HOST="${ELM_WATCH_HOST:-"127.0.0.1"}"
Environment=PATH=$(dirname "$(command -v elm-review)"):$PATH
ExecStart=$(command -v elm-watch) hot
EOT

# Remark(correctness): --serve-fallback= prevents 404 errors
# eg. on forge-config.json
# but required to reload in the browser at non-root URLs.
systemctl --user edit --runtime --force --full "$unit"-esbuild.service --stdin <<EOT
[Unit]
After=$unit-elm-watch.service
Requires=$unit-elm-watch.service

[Service]
Type=simple
Slice=$slice.slice
WorkingDirectory=$rootDir/ui
Environment=PATH=$PATH
ExecStart=@runtimeShell@ -xc 'shopt -s nullglob; exec esbuild \\
  --bundle \\
  --loader:.html=copy \\
  --outbase=src \\
  --outdir=build \\
  --serve=$listenPort \\
  --servedir=build \\
  --serve-fallback=src/index.html \\
  --sourcemap=external \\
  --watch=forever \\
  src/**/*.css \\
  src/**/*.html \\
  src/**/*.js'
EOT

# Note: using `watchman watch-project`
# would not support working in a non-default git-worktree or jj-workspace.
# Remark(resiliency): if the systemd unit in watchman fails,
# `systemctl --user reset-failed`
# needs to be called (eg. by rerunning this script).
watchman watch .
watchman -j <<EOT
[ "trigger"
, "$PWD"
, {
    "name": "$unit-config",
    "command": [ "systemctl", "--user", "restart", "$unit-backend.service"
               ],
    "append_files": false,
    "expression": [
      "anyof",
      [
        "pcre",
        "^(forge|recipes)/.*\\\.nix\$",
        "wholename",
        {"includedotfiles": false}
      ]
    ]
  }
]
EOT

systemctl --user restart --no-block \
  "$unit"-esbuild.service
journalctl --since "-5s" --user -f \
  -u "$unit-*".service
