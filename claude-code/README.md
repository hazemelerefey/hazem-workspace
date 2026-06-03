# Claude Code + Agent Router — Quick Setup

## Prerequisites

- Claude Code installed (`npm install -g @anthropic-ai/claude-code`)
- Agent Router API key from https://agentrouter.org/console/token

Replace `YOUR_API_KEY` with your actual key in the commands below.

---

## Step 1: Set Environment Variables

### Windows PowerShell

```powershell
[System.IO.File]::AppendAllText($PROFILE, "`n# === Agent Router ===`n`$env:ANTHROPIC_BASE_URL=`"https://agentrouter.org/`"`n`$env:ANTHROPIC_API_KEY=`"YOUR_API_KEY`"`n")
```

### macOS / Linux

```bash
echo -e '\n# === Agent Router ===\nexport ANTHROPIC_BASE_URL=https://agentrouter.org/\nexport ANTHROPIC_API_KEY=YOUR_API_KEY' >> ~/.bashrc
```

---

## Step 2: Set Default Model

Copy `settings.json` to `~/.claude/settings.json`:

### Windows PowerShell

```powershell
Copy-Item settings.json ~/.claude/settings.json
```

### macOS / Linux

```bash
cp settings.json ~/.claude/settings.json
```

---

## Step 3: Clear Old Cache

### Windows PowerShell

```powershell
rm -Force -Recurse ~/.claude/cache/* 2>$null
rm -Force -Recurse ~/.claude/sessions/* 2>$null
```

### macOS / Linux

```bash
rm -rf ~/.claude/cache/* ~/.claude/sessions/*
```

---

## Step 4: Launch

Close your terminal, open a new one, then run:

```bash
claude
```

---

## Switch Models

Run inside Claude Code:

```
/model claude-opus-4-6
```

```
/model claude-haiku-4-5-20251001
```

| Model | ID | Use for |
|-------|----|---------|
| Opus 4.6 | `claude-opus-4-6` | Best quality, complex tasks |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | Fast, cheap, quick answers |

---

## Troubleshooting

### Auth conflict warning

Remove `AUTH_TOKEN` if it exists:

**Windows PowerShell:**

```powershell
[System.IO.File]::ReadAllText($PROFILE) -replace '.*AUTH_TOKEN.*\r?\n?', '' | Set-Content $PROFILE
```

**macOS / Linux:**

```bash
sed -i '/AUTH_TOKEN/d' ~/.bashrc
```

### Model not found error

Clear cache and restart:

```bash
rm -rf ~/.claude/cache/*
```

Then close terminal, open a new one, run `claude`.

### Timeout on first call

The first call is slow (system prompt caching). Subsequent calls are fast.

---

## What This Does

| Variable | Value | Purpose |
|----------|-------|---------|
| `ANTHROPIC_BASE_URL` | `https://agentrouter.org/` | Routes API calls through Agent Router |
| `ANTHROPIC_API_KEY` | Your key | Authenticates with Agent Router |
| `model` in settings.json | `claude-opus-4-6` | Forces a model Agent Router supports |

**Do NOT set `ANTHROPIC_AUTH_TOKEN`** — it causes auth conflicts. Only `ANTHROPIC_API_KEY` is needed.
