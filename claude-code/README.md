# Claude Code Setup

## One Command

**Windows:**
```powershell
irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/claude-code/setup.ps1 | iex
```

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/claude-code/setup.sh | bash
```

## What It Does

1. Installs Claude Code CLI
2. Sets model to `claude-opus-4-6`
3. Configures Agent Router env vars
4. Clears old cache
5. Restores sessions from backup

## After Setup

```bash
claude          # Launch Claude Code
/model claude-opus-4-6     # Switch to Opus
/model claude-haiku-4-5-20251001  # Switch to Haiku
```

## Files

- `setup.ps1` — Windows setup script
- `setup.sh` — macOS/Linux setup script
- `settings.json` — Claude Code config
- `sessions/` — Session backups
