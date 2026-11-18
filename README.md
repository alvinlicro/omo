# OMO Native v5 Team Setup

Standalone [OMO Native](https://github.com/code-yeongyu/oh-my-openagent/blob/HEAD/docs/guide/installation.md#omo-native-omo-via-omo-ai) configured for the company **ai-prod** and **LLMConnector** gateways.

No OpenCode install, plugin registration, base URLs, or model edits required. Enter two tokens and start `omo`.

## Prerequisites

- macOS or Linux
- [Bun](https://bun.sh/) recommended, or Node.js 24+ with npm
- An **ai-prod API token**
- An **LLMConnector API token**

Ask IT or the internal AI portal administrator for token access. Tokens are personal credentials; do not share or commit them.

## Setup

From this repository, run:

```bash
./setup.sh
```

The installer:

1. Installs OMO Native v5 directly from the `omo-ai` package (`bun add -g omo-ai`, or `npm i -g omo-ai`).
2. Backs up any existing OMO configuration it replaces.
3. Installs the fixed ai-prod and LLMConnector provider configuration and team model routing.
4. Prompts for the two tokens without displaying them.
5. Stores tokens as owner-only files under `~/.omo/agent/secrets/`.

Press Enter at a token prompt to keep an existing saved token. A first-time setup requires both tokens.

| Gateway | Saved token |
| --- | --- |
| ai-prod | `~/.omo/agent/secrets/ai-prod.key` |
| LLMConnector | `~/.omo/agent/secrets/llmconnector.key` |

No shell restart or `.zshrc` edit is needed.

## Start and verify

```bash
omo doctor
omo --list-models llmconnector
omo --list-models ai-prod
omo
```

The default profile starts on LLMConnector Kimi K3.1 Pro, with ai-prod and other LLMConnector models as fallbacks. Use `/model` inside OMO to choose another model.

Smoke-test both gateways from the shell:

```bash
omo -p --model 'llmconnector/llmproxy/moonshotai/kimi-k3.1-pro' 'Reply with OK only.'
omo -p --model 'ai-prod/openai.gpt-6.1-sol' 'Reply with OK only.'
```

## Installed configuration

| File | Purpose |
| --- | --- |
| `~/.omo/agent/models.json` | Fixed gateway URLs, protocols, model catalogs, and token-file references |
| `~/.omo/agent/settings.json` | Default interactive model and fallback behavior |
| `~/.omo/omo.jsonc` | Native main-session profile, agent routing, and category routing |
| `~/.omo/agent/secrets/` | Personal tokens, mode `0600`; never read from this repository |

The routing uses only Native-supported agents and categories. OpenCode-era `oh-my-openagent.json` configuration is not used.

## Update or repair

Update OMO itself:

```bash
omo update
```

Refresh team configuration or replace a token:

```bash
./setup.sh
```

Re-running setup is safe. Existing files receive timestamped backups before replacement, and an empty token prompt preserves the saved token.

If `omo --version` prints an old bare version such as `4.19.4`, a legacy OpenCode-edition command still shadows Native. Run `bunx oh-my-openagent@latest install --platform=native --no-tui` (or `npx oh-my-openagent@latest install --platform=native --no-tui`) once to remove the stale command, then rerun `./setup.sh`. If `omo` is not on PATH, add the global Bun/npm bin directory to PATH and open a new terminal.

If a smoke test returns an authentication error, rerun setup and enter a fresh token for that gateway. If both gateways fail, check VPN/internal-network access first.

## Uninstall

```bash
bun remove -g omo-ai
```

Use `npm uninstall -g omo-ai` if npm installed it. OMO state remains under `~/.omo/`; remove that directory yourself only if you also want to erase sessions, configuration, and saved tokens.

Official references: [Native installation](https://github.com/code-yeongyu/oh-my-openagent/blob/HEAD/docs/guide/installation.md#omo-native-omo-via-omo-ai) and [migration from OpenCode](https://github.com/code-yeongyu/oh-my-openagent/blob/HEAD/docs/guide/migrating-from-opencode.md).
