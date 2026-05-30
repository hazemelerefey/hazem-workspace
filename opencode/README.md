# OpenCode Configuration

Portable, fully-configured OpenCode — clone and run, zero setup.

## Command Execute

### Setup on a new PC

```bash
git clone https://github.com/hazemelerefey/opencode-config ~/.opencode
bash ~/.opencode/scripts/setup.sh
opencode
```

### Sync sessions to GitHub (after working)

```bash
bash ~/.opencode/scripts/backup-sessions.sh
```

### Sync sessions from GitHub (on another PC)

```bash
cd ~/.opencode && git pull && bash ~/.opencode/scripts/setup.sh
```

## Structure

```
~/.opencode/
├── agent/          # AI agents
├── command/        # Custom commands (test, commit, quota, etc.)
├── configs/        # Pre-configured files with API keys
│   ├── opencode.jsonc      →  ~/.config/opencode/opencode.jsonc
│   ├── .gitconfig           →  ~/.gitconfig
│   └── .git-credentials     →  ~/.git-credentials
├── context/        # Standards, workflows, project intelligence
├── skills/         # LinkedIn, task management, etc.
├── sessions/       # Session history (37 sessions)
├── scripts/        # Setup utilities
│   ├── setup.sh             # One-command setup
│   ├── backup-sessions.sh   # Push latest sessions
│   └── restore-sessions.sh  # Restore sessions
├── plugin/         # Quota tracker
├── reference/      # Personal data
├── telegram/       # Telegram bot (token included)
└── tool/           # Env tool
```
