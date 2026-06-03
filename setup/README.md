# One-Command Setup

## Quick Start

### Windows PowerShell (run as Admin)

```powershell
irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/setup/setup.ps1 | iex
```

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/setup/setup.sh | bash
```

---

## What It Installs

| Tool | Version | Purpose |
|------|---------|---------|
| Claude Code | latest | AI coding agent (Opus 4.6 via Agent Router) |
| Hermes Agent | latest | AI assistant CLI (MiMo v2.5-pro) |

## What It Configures

- `~/.claude/settings.json` — Claude Code model + effort
- `~/.claude/sessions/` — Restored session history
- PowerShell profile / `.bashrc` — Agent Router env vars
- Hermes config — MiMo model provider

## After Setup

```bash
claude          # Launch Claude Code (Opus 4.6)
hermes          # Launch Hermes Agent (MiMo v2.5-pro)
```

## Update API Keys

Edit the top of `setup.ps1` or `setup.sh`:

```powershell
$AGENT_ROUTER_KEY = "sk-your-new-key"
$MIMO_KEY         = "sk-your-new-key"
```

Then re-run the script.

## Clone + Setup (Two Commands)

```bash
git clone https://github.com/hazemelerefey/hazem-workspace.git ~/hazem-workspace
cd ~/hazem-workspace/setup && ./setup.sh   # or: .\setup.ps1 on Windows
```
