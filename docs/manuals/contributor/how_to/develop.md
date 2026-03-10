# How to develop

Enter a development shell provisioning the toolchain:
```bash
nix -L develop
```

Alternatively, use [`direnv`](https://direnv.net/):
```bash
direnv allow
```

Warning(compat): If you ever want to debug a package using
`nix develop` and then run the usual `runPhase unpackPhase`,
first get out of the `direnv` with `direnv deny` to avoid problems.

## Run a development Web server

Run `elm-watch` and `esbuild` systemd user services,
along with a `watchman` rebuilding the JSON files provided by the backend,
with:
```bash
dev-ui
```

End the services by sending them a SIGINT (usually Ctrl-C).

You can supervise those services with:
```bash
systemctl --user status ngi-nix-app-store-dev-'*'.service
```

For convenience `systemd-manager-tui` is also provisioned by the development shell to do the same.
