# Claude Code + Agent Router — One-Click Setup

Replace `YOUR_API_KEY` with your Agent Router key, then run the commands for your OS.

---

## Windows PowerShell

```powershell
# 1. Install Claude Code
npm install -g @anthropic-ai/claude-code

# 2. Set environment variables (adds to profile permanently)
[System.IO.File]::AppendAllText($PROFILE, "`n# === Agent Router ===`n`$env:ANTHROPIC_BASE_URL=`"https://agentrouter.org/`"`n`$env:ANTHROPIC_API_KEY=`"YOUR_API_KEY`"`n")

# 3. Set model
'{"model":"claude-opus-4-6"}' | Out-File -Encoding utf8 ~/.claude/settings.json

# 4. Clear cache
rm -Force -Recurse ~/.claude/cache/* 2>$null
rm -Force -Recurse ~/.claude/sessions/* 2>$null

# 5. Apply env vars to current session
$env:ANTHROPIC_BASE_URL="https://agentrouter.org/"
$env:ANTHROPIC_API_KEY="YOUR_API_KEY"

# 6. Test
claude -p "say hello" --max-turns 1

# 7. Launch interactive
claude
```

---

## macOS / Linux

```bash
# 1. Install Claude Code
npm install -g @anthropic-ai/claude-code

# 2. Set environment variables (adds to profile permanently)
echo -e '\n# === Agent Router ===\nexport ANTHROPIC_BASE_URL=https://agentrouter.org/\nexport ANTHROPIC_API_KEY=YOUR_API_KEY' >> ~/.bashrc
source ~/.bashrc

# 3. Set model
echo '{"model":"claude-opus-4-6"}' > ~/.claude/settings.json

# 4. Clear cache
rm -rf ~/.claude/cache/* ~/.claude/sessions/*

# 5. Test
claude -p "say hello" --max-turns 1

# 6. Launch interactive
claude
```

---

## Switch Models (inside Claude Code)

```
/model claude-opus-4-6
/model claude-haiku-4-5-20251001
```

---

## If It Fails

1. **Auth conflict** — remove AUTH_TOKEN if it exists:
   ```powershell
   # Windows
   [System.IO.File]::ReadAllText($PROFILE) -replace '.*AUTH_TOKEN.*\r?\n?', '' | Set-Content $PROFILE
   ```
   ```bash
   # macOS/Linux
   sed -i '/AUTH_TOKEN/d' ~/.bashrc ~/.zshrc 2>/dev/null
   ```

2. **Model not found** — clear cache and restart terminal:
   ```bash
   rm -rf ~/.claude/cache/*
   ```

3. **Timeout on first call** — normal, system prompt caching. Wait up to 2 minutes.

---

## What It Does

| Variable | Value | Purpose |
|----------|-------|---------|
| `ANTHROPIC_BASE_URL` | `https://agentrouter.org/` | Routes through Agent Router |
| `ANTHROPIC_API_KEY` | Your key | Auth |
| `model` | `claude-opus-4-6` | Default model |

**Only set `ANTHROPIC_API_KEY`. Do NOT set `ANTHROPIC_AUTH_TOKEN`.**
