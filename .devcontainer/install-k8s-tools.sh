#!/usr/bin/env bash
set -euo pipefail

KUBECTX_VERSION="v0.9.5"
KUBECTX_BASE_URL="https://raw.githubusercontent.com/ahmetb/kubectx/${KUBECTX_VERSION}"

ensure_local_bin_in_path() {
  mkdir -p "$HOME/.local/bin"
  if ! grep -q '\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  fi
}

install_to_path() {
  local name="$1"
  local src="$2"

  if command -v "$name" >/dev/null 2>&1; then
    echo "$name already installed: $(command -v "$name")"
    return 0
  fi

  if sudo install -m 755 "$src" "/usr/local/bin/$name" 2>/dev/null; then
    echo "Installed $name to /usr/local/bin/$name"
  else
    ensure_local_bin_in_path
    install -m 755 "$src" "$HOME/.local/bin/$name"
    echo "Installed $name to $HOME/.local/bin/$name"
  fi
}

install_k9s() {
  if command -v k9s >/dev/null 2>&1; then
    echo "k9s already installed: $(command -v k9s)"
    return 0
  fi

  local k9s_arch
  case "$(uname -m)" in
    x86_64) k9s_arch="Linux_amd64" ;;
    aarch64|arm64) k9s_arch="Linux_arm64" ;;
    *)
      echo "Unsupported architecture for k9s: $(uname -m)" >&2
      return 1
      ;;
  esac

  local tmpdir
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN

  curl -sSL "https://github.com/derailed/k9s/releases/latest/download/k9s_${k9s_arch}.tar.gz" \
    | tar -xz -C "$tmpdir" k9s

  install_to_path k9s "$tmpdir/k9s"
}

install_kubectx_kubens() {
  if command -v kubectx >/dev/null 2>&1 && command -v kubens >/dev/null 2>&1; then
    echo "kubectx already installed: $(command -v kubectx)"
    echo "kubens already installed: $(command -v kubens)"
    return 0
  fi

  local tmpdir
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN

  curl -sSL "${KUBECTX_BASE_URL}/kubectx" -o "$tmpdir/kubectx"
  curl -sSL "${KUBECTX_BASE_URL}/kubens" -o "$tmpdir/kubens"
  chmod +x "$tmpdir/kubectx" "$tmpdir/kubens"

  install_to_path kubectx "$tmpdir/kubectx"
  install_to_path kubens "$tmpdir/kubens"
}

install_kubectx_kubens
install_k9s
