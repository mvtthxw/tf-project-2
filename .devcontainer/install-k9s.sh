#!/usr/bin/env bash
set -euo pipefail

if command -v k9s >/dev/null 2>&1; then
  echo "k9s already installed: $(k9s version | head -n 1)"
  exit 0
fi

case "$(uname -m)" in
  x86_64) k9s_arch="Linux_amd64" ;;
  aarch64|arm64) k9s_arch="Linux_arm64" ;;
  *)
    echo "Unsupported architecture for k9s: $(uname -m)" >&2
    exit 1
    ;;
esac

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

curl -sSL "https://github.com/derailed/k9s/releases/latest/download/k9s_${k9s_arch}.tar.gz" \
  | tar -xz -C "$tmpdir" k9s

if sudo mv "$tmpdir/k9s" /usr/local/bin/k9s 2>/dev/null; then
  sudo chmod +x /usr/local/bin/k9s
  echo "Installed k9s to /usr/local/bin/k9s"
else
  mkdir -p "$HOME/.local/bin"
  mv "$tmpdir/k9s" "$HOME/.local/bin/k9s"
  chmod +x "$HOME/.local/bin/k9s"
  if ! grep -q '\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  fi
  echo "Installed k9s to $HOME/.local/bin/k9s"
fi

k9s version | head -n 1
