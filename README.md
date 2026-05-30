# Hazem Workspace

> My complete portable AI development environment — one command to set up any new PC.

## Command Execute

| Component | Command | Size | Status |
|---|---|---|---|
| **hazem-env** | `bash setup.sh env` | ~1.5 GB | ✅ Ready |
| **opencode** | `bash setup.sh opencode` | ~150 MB | ✅ Ready |
| **hermes** | `bash setup.sh hermes` | TBD | ⏳ Planned |
| **openclaw** | `bash setup.sh openclaw` | TBD | ⏳ Planned |
| **hazem-env + opencode** | `bash setup.sh all` | ~1.65 GB | ✅ Ready |

### Quick Start on a New PC

```bash
# Option A: Everything (env + opencode)
curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/setup.sh | bash -s -- all

# Option B: Environment only (ZSH, languages, tools, Docker)
curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/setup.sh | bash -s -- env

# Option C: OpenCode only (configs, agents, sessions)
curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/setup.sh | bash -s -- opencode
```

### Sync Sessions Between PCs

```bash
# After working on PC A — push sessions
cd ~/.opencode
cp ~/.local/share/opencode/opencode.db sessions/
cp ~/.local/share/opencode/quota-tracker.json sessions/
git add -A && git commit -m "Update sessions" && git push

# On PC B — pull sessions
cd ~/.opencode && git pull
bash ~/.opencode/scripts/restore-sessions.sh
```

---

## Structure

```
hazem-workspace/
├── setup.sh              ← Universal entry point (bash setup.sh [component])
├── README.md             ← This file
│
├── scripts/              ← Installer modules
│   ├── install-core.sh        # ZSH + Oh My Zsh + Powerlevel10k + plugins
│   ├── install-languages.sh   # Python, Node (nvm), Go, Rust
│   ├── install-tools.sh       # bat, ripgrep, fd, fzf, tmux, lazygit, jq
│   ├── install-docker.sh      # Docker Engine + Compose
│   ├── link-dotfiles.sh       # Symlink shell/config files to ~/
│   └── restore-sessions.sh    # Copy sessions to ~/.local/share/opencode/
│
├── shell/                # Shell dotfiles (symlinked to ~/)
│   ├── .zshrc
│   ├── .bashrc
│   ├── .aliases
│   ├── .exports
│   └── .functions
│
├── configs/              # Tool configs
│   ├── .gitconfig
│   ├── .git-credentials
│   ├── .tmux.conf
│   └── opencode.jsonc    # → ~/.config/opencode/opencode.jsonc
│
├── opencode/             # Full OpenCode config (agents, skills, context, sessions)
│   ├── agent/
│   ├── skills/
│   ├── context/
│   ├── sessions/         # 37 conversations + quota tracker
│   └── ...
│
├── hermes/               # Placeholder — future
│   └── README.md
│
└── openclaw/             # Placeholder — future
    └── README.md
```

---

## What's Included

### Shell
- **ZSH** with Oh My Zsh + Powerlevel10k theme
- Autosuggestions + syntax highlighting plugins
- Smart aliases for git, Docker, Python, navigation

### Languages & Runtimes
- **Python 3.12** — latest stable, with pip + pipx + uv
- **Node.js** — latest LTS via NVM
- **Go** — latest stable
- **Rust** — via rustup

### CLI Tools
- `bat` — cat with syntax highlighting
- `ripgrep` — 10x faster grep
- `fd` — faster find
- `fzf` — fuzzy search anything
- `tmux` — terminal multiplexer
- `lazygit` — Git TUI
- `jq` — JSON processor

### Docker
- Docker Engine + Docker Compose
- Pre-configured for WSL

### OpenCode
- Full agent configuration (OpenAgent, CoderAgent, TestEngineer, etc.)
- All skills (LinkedIn automation, task management, CLI)
- Complete context system (standards, workflows, project intelligence)
- 37 saved sessions with full conversation history
- Telegram bot integration
- API keys pre-configured

---

## Requirements

- **OS:** Ubuntu 24.04+ (or WSL on Windows)
- **Internet:** Downloads ~1.5 GB of packages
- **Time:** ~5-10 minutes for full setup
