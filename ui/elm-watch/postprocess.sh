#!/usr/bin/env bash
set -eu
target_name="$1"
compilation_mode="$2"
run_mode="$3"

case "$compilation_mode" in
debug)
  #elm-review --no-color >&2
  cat
  ;;
standard)
  cat
  ;;
optimize)
  elm-test-rs >&2
  esbuild --minify
  ;;
*)
  echo "Unknown compilation mode: $compilation_mode"
  exit 1
  ;;
esac
