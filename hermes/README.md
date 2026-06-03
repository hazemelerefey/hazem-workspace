# Hermes Agent Setup

## One Command

**Windows:**
```powershell
irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/hermes/setup.ps1 | iex
```

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/hermes/setup.sh | bash
```

## What It Does

1. Installs Hermes Agent via pip
2. Configures MiMo v2.5-pro as default model
3. Restores skills from backup (if available)

## After Setup

```bash
hermes          # Launch Hermes Agent
```

## Model

MiMo v2.5-pro via Xiaomi API — same model Hermes runs on.

## Files

- `setup.ps1` — Windows setup script
- `setup.sh` — macOS/Linux setup script
- `skills/` — Skills backups (optional)
