#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMO_ROOT="$HOME/.omo"
AGENT_DIR="$OMO_ROOT/agent"
SECRETS_DIR="$AGENT_DIR/secrets"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

echo "=== OMO Native v5: ai-prod + LLMConnector ==="
echo

if command -v bunx >/dev/null 2>&1; then
  bunx oh-my-openagent@latest install --platform=native --no-tui
elif command -v npx >/dev/null 2>&1; then
  NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
  if [[ "$NODE_MAJOR" -lt 24 ]]; then
    echo "Node.js 24 or newer is required. Upgrade Node.js or install Bun, then rerun setup." >&2
    exit 1
  fi
  npx oh-my-openagent@latest install --platform=native --no-tui
else
  echo "Install Bun (recommended) or Node.js 24+ with npm, then rerun setup." >&2
  exit 1
fi

hash -r
if ! command -v omo >/dev/null 2>&1; then
  echo "OMO was installed but is not on PATH. Open a new terminal or apply the installer's PATH fix, then rerun setup." >&2
  exit 1
fi

VERSION="$(omo --version)"
if [[ "$VERSION" != omo\ 5.* ]]; then
  echo "Expected OMO Native v5, found: $VERSION" >&2
  echo "Apply the installer's PATH fix for the legacy omo command, then rerun setup." >&2
  exit 1
fi

echo "Configuring $AGENT_DIR"
mkdir -p "$AGENT_DIR" "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"

backup_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    cp -p "$path" "$path.backup-$TIMESTAMP"
    echo "Backed up $(basename "$path")"
  fi
}

install_config() {
  local source="$1"
  local destination="$2"
  backup_file "$destination"
  cp "$source" "$destination"
  chmod 600 "$destination"
}

install_config "$SCRIPT_DIR/.omo/agent/models.json" "$AGENT_DIR/models.json"
install_config "$SCRIPT_DIR/.omo/agent/settings.json" "$AGENT_DIR/settings.json"
install_config "$SCRIPT_DIR/.omo/omo.jsonc" "$OMO_ROOT/omo.jsonc"

umask 077
prompt_secret() {
  local label="$1"
  local path="$2"
  local value=""

  if [[ -s "$path" ]]; then
    read -r -s -p "$label [Enter keeps saved token]: " value
  else
    read -r -s -p "$label: " value
  fi
  echo

  if [[ -n "$value" ]]; then
    printf '%s\n' "$value" >"$path"
    chmod 600 "$path"
    echo "Saved $label"
  elif [[ -s "$path" ]]; then
    echo "Kept saved $label"
  else
    echo "$label is required for first-time setup." >&2
    exit 1
  fi
}

prompt_secret "ai-prod API token" "$SECRETS_DIR/ai-prod.key"
prompt_secret "LLMConnector API token" "$SECRETS_DIR/llmconnector.key"

echo
echo "=== Setup complete: $VERSION ==="
echo "Run 'omo' to start."
echo "Run 'omo doctor' to inspect the installation."
