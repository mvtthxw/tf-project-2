#!/usr/bin/env bash
set -euo pipefail

print_line() {
  local label="$1"
  local value="$2"
  printf '%-12s %s\n' "$label" "$value"
}

strip_ansi() {
  sed -E 's/\x1B\[[0-9;]*[mK]//g'
}

tool_version() {
  local label="$1"
  shift

  local value
  if value=$("$@" 2>/dev/null | strip_ansi); then
    value="${value%%$'\n'*}"
    if [[ -n "$value" ]]; then
      print_line "$label" "$value"
      return
    fi
  fi

  print_line "$label" "not installed"
}

echo "=== Devcontainer tools ==="
tool_version "terraform" terraform version
tool_version "kubectl" bash -c 'kubectl version --client 2>/dev/null | head -n 1'
tool_version "helm" helm version --short
tool_version "k9s" bash -c 'k9s version 2>/dev/null | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | head -n 1'
tool_version "kubectx" command -v kubectx
tool_version "kubens" command -v kubens
tool_version "php" bash -c 'php -v | head -n 1'
tool_version "docker" docker --version
tool_version "aws" aws --version
tool_version "gh" bash -c 'gh --version | head -n 1'
tool_version "python" python3 --version
echo "=========================="
