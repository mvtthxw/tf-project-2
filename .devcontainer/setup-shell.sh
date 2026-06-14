#!/usr/bin/env bash
set -euo pipefail

ALIASES_MARKER="kubectl-aliases.sh"
ALIASES_PATH="/workspaces/tf-project-2/.devcontainer/kubectl-aliases.sh"

if ! grep -q "$ALIASES_MARKER" "$HOME/.bashrc" 2>/dev/null; then
  echo "source \"$ALIASES_PATH\"" >> "$HOME/.bashrc"
  echo "Added kubectl aliases to ~/.bashrc"
else
  echo "kubectl aliases already configured in ~/.bashrc"
fi
