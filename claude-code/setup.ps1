# ============================================================
#  Claude Code + Agent Router Setup — Windows PowerShell
#  One command: irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/claude-code/setup.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Claude Code Setup (Agent Router)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- API Key ---
$AGENT_ROUTER_KEY = "sk-2DiZntY7Qu5yGz5PCIyromiv9ABoXpW5mtyawyrYyL4ZWfC6"

# ============================================
# 1. Install Claude Code
# ============================================
Write-Host "--- Installing Claude Code ---" -ForegroundColor Yellow

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "[✓] Claude Code found: $(claude --version 2>&1)" -ForegroundColor Green
} else {
    npm install -g @anthropic-ai/claude-code
    Write-Host "[✓] Claude Code installed" -ForegroundColor Green
}

# ============================================
# 2. Claude Config
# ============================================
Write-Host "`n--- Config ---" -ForegroundColor Yellow

$claudeDir = "$env:USERPROFILE\.claude"
if (!(Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }

'{"model":"claude-opus-4-6"}' | Out-File -Encoding utf8 "$claudeDir\settings.json"
Write-Host "[✓] settings.json" -ForegroundColor Green

# Clear cache
Remove-Item -Path "$claudeDir\cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$claudeDir\sessions\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[✓] Cache cleared" -ForegroundColor Green

# ============================================
# 3. Environment Variables
# ============================================
Write-Host "`n--- Env Vars ---" -ForegroundColor Yellow

$profileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

# Read existing profile, remove old Agent Router / MiMo entries
$existing = ""
if (Test-Path $PROFILE) { $existing = Get-Content $PROFILE -Raw }
$existing = $existing -replace '(?m)^# === Agent Router.*\r?\n?', ''
$existing = $existing -replace '(?m)^# === Xiaomi MiMo.*\r?\n?', ''
$existing = $existing -replace '(?m)^.*ANTHROPIC_BASE_URL.*\r?\n?', ''
$existing = $existing -replace '(?m)^.*ANTHROPIC_API_KEY.*\r?\n?', ''
$existing = $existing -replace '(?m)^.*ANTHROPIC_AUTH_TOKEN.*\r?\n?', ''

$envBlock = @"

# === Agent Router (Claude Code) ===
`$env:ANTHROPIC_BASE_URL="https://agentrouter.org/"
`$env:ANTHROPIC_API_KEY="$AGENT_ROUTER_KEY"
"@

$newProfile = $existing.TrimEnd() + "`n" + $envBlock
[System.IO.File]::WriteAllText($PROFILE, $newProfile)
Write-Host "[✓] Profile updated" -ForegroundColor Green

# Apply now
$env:ANTHROPIC_BASE_URL = "https://agentrouter.org/"
$env:ANTHROPIC_API_KEY  = $AGENT_ROUTER_KEY
Write-Host "[✓] Env vars applied" -ForegroundColor Green

# ============================================
# 4. Restore Sessions
# ============================================
Write-Host "`n--- Sessions ---" -ForegroundColor Yellow

$sessionBackup = "$env:USERPROFILE\hazem-workspace\claude-code\sessions"
if (Test-Path $sessionBackup) {
    Copy-Item -Path "$sessionBackup\projects\*" -Destination "$claudeDir\projects\" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$sessionBackup\sessions\*" -Destination "$claudeDir\sessions\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[✓] Sessions restored" -ForegroundColor Green
} else {
    Write-Host "[!] No backup found — clone repo first:" -ForegroundColor Yellow
    Write-Host "    git clone https://github.com/hazemelerefey/hazem-workspace.git ~/hazem-workspace"
}

# ============================================
# 5. Done
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Claude Code Ready!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Close PowerShell, reopen, then run:" -ForegroundColor Cyan
Write-Host "    claude" -ForegroundColor White
Write-Host ""
Write-Host "  Switch models:" -ForegroundColor Cyan
Write-Host "    /model claude-opus-4-6" -ForegroundColor White
Write-Host "    /model claude-haiku-4-5-20251001" -ForegroundColor White
Write-Host ""
