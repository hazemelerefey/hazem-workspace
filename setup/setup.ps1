# ============================================================
#  Hazem's Full Dev Environment Setup — Windows PowerShell
#  One command: irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/setup/setup.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"
$GREEN = "`e[32m"; $YELLOW = "`e[33m"; $RED = "`e[31m"; $RESET = "`e[0m"

function Log($msg)  { Write-Host "${GREEN}[✓]${RESET} $msg" }
function Warn($msg) { Write-Host "${YELLOW}[!]${RESET} $msg" }
function Err($msg)  { Write-Host "${RED}[✗]${RESET} $msg" }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Hazem Dev Environment Setup (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Config (edit these when API keys change) ---
$AGENT_ROUTER_KEY = "sk-2DiZntY7Qu5yGz5PCIyromiv9ABoXpW5mtyawyrYyL4ZWfC6"
$MIMO_KEY         = "sk-sww798prqp55b7c4yhbsstumszvwza48jn1b7fhq8gaieow3"
$COMPOSIO_KEY     = "ak_HiyqXrz8dU_ijR35vesS"
$COMPOSIO_URL     = "https://backend.composio.dev/tool_router/trs_XKI7uBm-Oo1q/mcp"

# ============================================
# 1. Prerequisites Check
# ============================================
Write-Host "`n--- Prerequisites ---" -ForegroundColor Yellow

# Node.js
$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
    Log "Node.js found: $(node --version)"
} else {
    Warn "Node.js not found. Install from https://nodejs.org then re-run this script."
    exit 1
}

# Git
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) {
    Log "Git found: $(git --version)"
} else {
    Warn "Git not found. Install from https://git-scm.com then re-run this script."
    exit 1
}

# npm
$npm = Get-Command npm -ErrorAction SilentlyContinue
if ($npm) {
    Log "npm found: $(npm --version)"
} else {
    Err "npm not found. Reinstall Node.js."
    exit 1
}

# ============================================
# 2. Install Claude Code
# ============================================
Write-Host "`n--- Claude Code ---" -ForegroundColor Yellow

$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) {
    Log "Claude Code found: $(claude --version 2>&1)"
} else {
    Warn "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    if ($LASTEXITCODE -eq 0) { Log "Claude Code installed" } else { Err "Claude Code install failed" }
}

# ============================================
# 3. Install Hermes Agent
# ============================================
Write-Host "`n--- Hermes Agent ---" -ForegroundColor Yellow

$hermes = Get-Command hermes -ErrorAction SilentlyContinue
if ($hermes) {
    Log "Hermes found: $(hermes --version 2>&1 | Select-Object -First 1)"
} else {
    Warn "Installing Hermes Agent..."
    pip install hermes-agent
    if ($LASTEXITCODE -eq 0) { Log "Hermes installed" } else { Err "Hermes install failed" }
}

# ============================================
# 4. Claude Code Config
# ============================================
Write-Host "`n--- Claude Code Config ---" -ForegroundColor Yellow

$claudeDir = "$env:USERPROFILE\.claude"
if (!(Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }

# settings.json
$settingsJson = @{
    model = "claude-opus-4-6"
} | ConvertTo-Json
[System.IO.File]::WriteAllText("$claudeDir\settings.json", $settingsJson)
Log "settings.json written"

# Clear cache
Remove-Item -Path "$claudeDir\cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$claudeDir\sessions\*" -Recurse -Force -ErrorAction SilentlyContinue
Log "Cache cleared"

# ============================================
# 5. PowerShell Profile
# ============================================
Write-Host "`n--- PowerShell Profile ---" -ForegroundColor Yellow

$profileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

$profileContent = @"
# === Oh My Posh Theme ===
`$ompTheme = "`$env:LOCALAPPDATA\oh-my-posh\themes\paradox.omp.json"
if (Test-Path `$ompTheme) { oh-my-posh init pwsh --config `$ompTheme | Invoke-Expression }

# === PSReadLine ===
Import-Module PSReadLine -ErrorAction SilentlyContinue
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# === Aliases ===
Set-Alias -Name g -Value git
Set-Alias -Name c -Value clear
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name touch -Value New-Item

function gs { git status @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git log --oneline --graph --decorate -20 @args }
function gd { git diff @args }
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function mkcd { param(`$d) New-Item -ItemType Directory -Path `$d -Force | Out-Null; Set-Location `$d }
function ports { netstat -ano | Select-String LISTENING }
function myip { (Invoke-WebRequest -Uri "https://ifconfig.me" -UseBasicParsing).Content }

# === Environment ===
`$env:EDITOR = "code"
`$env:PYTHONIOENCODING = "utf-8"
`$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"

# === Agent Router (Claude Code) ===
`$env:ANTHROPIC_BASE_URL="https://agentrouter.org/"
`$env:ANTHROPIC_API_KEY="$AGENT_ROUTER_KEY"
"@

[System.IO.File]::WriteAllText($PROFILE, $profileContent)
Log "PowerShell profile written"

# Apply to current session
$env:ANTHROPIC_BASE_URL = "https://agentrouter.org/"
$env:ANTHROPIC_API_KEY  = $AGENT_ROUTER_KEY
Log "Env vars applied to current session"

# ============================================
# 6. Hermes Config
# ============================================
Write-Host "`n--- Hermes Config ---" -ForegroundColor Yellow

$hermesDir = "$env:LOCALAPPDATA\hermes"
if (!(Test-Path $hermesDir)) { New-Item -ItemType Directory -Path $hermesDir -Force | Out-Null }

# Update model provider in config
$hermesConfigPath = "$hermesDir\config.yaml"
if (Test-Path $hermesConfigPath) {
    $config = Get-Content $hermesConfigPath -Raw
    # Update default model if needed
    if ($config -match 'default:.*mimo') {
        $config = $config -replace 'default:.*', "default: mimo-v2.5-pro"
        [System.IO.File]::WriteAllText($hermesConfigPath, $config)
        Log "Hermes config updated (model: mimo-v2.5-pro)"
    } else {
        Log "Hermes config exists (no changes needed)"
    }
} else {
    Warn "Hermes config not found — run 'hermes' once to generate it"
}

# ============================================
# 7. Restore Claude Sessions (if backup exists)
# ============================================
Write-Host "`n--- Session Restore ---" -ForegroundColor Yellow

$sessionBackup = "$env:USERPROFILE\hazem-workspace\claude-code\sessions"
if (Test-Path $sessionBackup) {
    $projectsSrc = "$sessionBackup\projects"
    $sessionsSrc = "$sessionBackup\sessions"

    if (Test-Path $projectsSrc) {
        Copy-Item -Path "$projectsSrc\*" -Destination "$claudeDir\projects\" -Recurse -Force -ErrorAction SilentlyContinue
        Log "Projects restored"
    }
    if (Test-Path $sessionsSrc) {
        Copy-Item -Path "$sessionsSrc\*" -Destination "$claudeDir\sessions\" -Recurse -Force -ErrorAction SilentlyContinue
        Log "Sessions restored"
    }
} else {
    Warn "No session backup found at $sessionBackup — skipping restore"
    Warn "Clone hazem-workspace first: git clone https://github.com/hazemelerefey/hazem-workspace.git ~/hazem-workspace"
}

# ============================================
# 8. Verify
# ============================================
Write-Host "`n--- Verification ---" -ForegroundColor Yellow

Write-Host "  Node.js:        $(node --version 2>&1)"
Write-Host "  npm:            $(npm --version 2>&1)"
Write-Host "  Git:            $(git --version 2>&1)"
Write-Host "  Claude Code:    $(claude --version 2>&1)"
Write-Host "  Hermes:         $(hermes --version 2>&1 | Select-Object -First 1)"
Write-Host "  ANTHROPIC_URL:  $env:ANTHROPIC_BASE_URL"
Write-Host "  ANTHROPIC_KEY:  $($env:ANTHROPIC_API_KEY.Substring(0,8))..."

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Close and reopen PowerShell"
Write-Host "  2. Run: claude          (launch Claude Code)"
Write-Host "  3. Run: hermes          (launch Hermes Agent)"
Write-Host ""
Write-Host "Switch models in Claude Code:" -ForegroundColor Cyan
Write-Host "  /model claude-opus-4-6"
Write-Host "  /model claude-haiku-4-5-20251001"
Write-Host ""
