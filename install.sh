#!/usr/bin/env bash
# Usage: install.sh [--global]   (run from inside the target repo for a local install)
set -e
src="$(cd "$(dirname "$0")" && pwd)/hooks"
chmod +x "$src"/*
if [ "${1:-}" = "--global" ]; then
  dest="$HOME/.config/git/hooks"; mkdir -p "$dest"
  cp "$src"/* "$dest"/
  git config --global core.hooksPath "$dest"
  echo "Installed globally to $dest"
else
  git config core.hooksPath "$src"
  echo "Repo now uses hooks from $src"
fi
