# Hazem Workspace

> My complete portable AI development environment — one command to set up any new PC.

## One-Command Setup

| Component | Windows | macOS / Linux |
|---|---|---|
| **Claude Code** | `irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/claude-code/setup.ps1 \| iex` | `curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/claude-code/setup.sh \| bash` |
| **Hermes Agent** | `irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/hermes/setup.ps1 \| iex` | `curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/hermes/setup.sh \| bash` |
| **hazem-env** | *(WSL)* `bash setup.sh env` | `bash setup.sh env` |
| **OpenCode** | *(WSL)* `bash setup.sh opencode` | `bash setup.sh opencode` |

### After Setup

```bash
claude    # Claude Code (Opus 4.6 via Agent Router)
hermes    # Hermes Agent (MiMo v2.5-pro via Xiaomi)
```

---

## What Each Setup Does

### Claude Code (Agent Router)
1. Installs Claude Code CLI
2. Sets model: `claude-opus-4-6`
3. Configures Agent Router env vars (API key baked in)
4. Clears cache
5. Restores sessions from backup

### Hermes Agent (MiMo)
1. Installs Hermes Agent via pip
2. Configures MiMo v2.5-pro as default model
3. Restores skills (if available)

### hazem-env
- ZSH + Oh My Zsh + Powerlevel10k
- Python, Node, Go, Rust
- CLI tools (bat, ripgrep, fd, fzf, tmux, lazygit, jq)
- Docker Engine + Compose

### OpenCode
- Full agent configuration
- All skills + context system
- 37 saved sessions
- Telegram bot integration

---

## Structure

```
hazem-workspace/
├── README.md
├── setup.sh                    ← Universal entry (bash setup.sh [component])
│
├── claude-code/                ← Claude Code + Agent Router
│   ├── setup.ps1                   Windows one-click
│   ├── setup.sh                    macOS/Linux one-click
│   ├── settings.json               Claude config
│   ├── sessions/                   Session backups
│   └── README.md
│
├── hermes/                     ← Hermes Agent + MiMo
│   ├── setup.ps1                   Windows one-click
│   ├── setup.sh                    macOS/Linux one-click
│   ├── skills/                     Skills backups
│   └── README.md
│
├── scripts/                    ← Installer modules (env/opencode)
│   ├── install-core.sh
│   ├── install-languages.sh
│   ├── install-tools.sh
│   ├── install-docker.sh
│   ├── link-dotfiles.sh
│   └── restore-sessions.sh
│
├── shell/                      ← Shell dotfiles
├── configs/                    ← Tool configs
├── opencode/                   ← Full OpenCode config
└── openclaw/                   ← Placeholder
```

---

## Update API Keys

Edit the top of each setup script:

**Claude Code** (`claude-code/setup.ps1` or `setup.sh`):
```
$AGENT_ROUTER_KEY = "sk-your-new-key"
```

**Hermes** (`hermes/setup.ps1` or `setup.sh`):
```
$MIMO_KEY = "sk-your-new-key"
```

Then re-run the setup command.

---

## Quick Start on a New PC

```bash
# 1. Clone the workspace
git clone https://github.com/hazemelerefey/hazem-workspace.git ~/hazem-workspace

# 2. Install Claude Code
# Windows PowerShell:
irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/claude-code/setup.ps1 | iex
# macOS/Linux:
curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/claude-code/setup.sh | bash

# 3. Install Hermes
# Windows PowerShell:
irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/hermes/setup.ps1 | iex
# macOS/Linux:
curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/hermes/setup.sh | bash

# 4. Open new terminal, run:
claude    # or
hermes
```
