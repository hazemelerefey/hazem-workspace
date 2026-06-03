# ============================================================
#  Hermes Agent Setup — Windows PowerShell
#  One command: irm https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/hermes/setup.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Hermes Agent Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- API Key ---
$MIMO_KEY = "sk-sww798prqp55b7c4yhbsstumszvwza48jn1b7fhq8gaieow3"

# ============================================
# 1. Install Python
# ============================================
Write-Host "--- Python ---" -ForegroundColor Yellow

if (Get-Command python -ErrorAction SilentlyContinue) {
    Write-Host "[✓] Python found: $(python --version 2>&1)" -ForegroundColor Green
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    Write-Host "[✓] Python3 found: $(python3 --version 2>&1)" -ForegroundColor Green
} else {
    Write-Host "[✗] Python not found. Install from https://python.org then re-run." -ForegroundColor Red
    exit 1
}

# ============================================
# 2. Install Hermes Agent
# ============================================
Write-Host "`n--- Hermes Agent ---" -ForegroundColor Yellow

if (Get-Command hermes -ErrorAction SilentlyContinue) {
    Write-Host "[✓] Hermes found: $(hermes --version 2>&1 | Select-Object -First 1)" -ForegroundColor Green
} else {
    Write-Host "[*] Installing Hermes Agent..." -ForegroundColor Yellow
    pip install hermes-agent
    Write-Host "[✓] Hermes installed" -ForegroundColor Green
}

# ============================================
# 3. Initialize Config (if missing)
# ============================================
Write-Host "`n--- Config ---" -ForegroundColor Yellow

$hermesDir = "$env:LOCALAPPDATA\hermes"
$configPath = "$hermesDir\config.yaml"

if (!(Test-Path $hermesDir)) { New-Item -ItemType Directory -Path $hermesDir -Force | Out-Null }

if (!(Test-Path $configPath)) {
    Write-Host "[*] First run — generating default config..." -ForegroundColor Yellow
    hermes --version 2>$null
}

# Update model to MiMo
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw
    $config = $config -replace 'default:.*', "default: mimo-v2.5-pro"
    $config = $config -replace 'provider:.*', "provider: xiaomi"
    [System.IO.File]::WriteAllText($configPath, $config)
    Write-Host "[✓] Config updated (MiMo v2.5-pro)" -ForegroundColor Green
} else {
    Write-Host "[!] Config not found — run 'hermes' once to generate it" -ForegroundColor Yellow
}

# ============================================
# 4. Restore Skills (if backup exists)
# ============================================
Write-Host "`n--- Skills ---" -ForegroundColor Yellow

$skillsBackup = "$env:USERPROFILE\hazem-workspace\hermes\skills"
$skillsDir = "$env:LOCALAPPDATA\hermes\skills"

if (Test-Path $skillsBackup) {
    if (!(Test-Path $skillsDir)) { New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null }
    Copy-Item -Path "$skillsBackup\*" -Destination $skillsDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[✓] Skills restored" -ForegroundColor Green
} else {
    Write-Host "[*] No skills backup — using defaults" -ForegroundColor Yellow
}

# ============================================
# 5. Done
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Hermes Agent Ready!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Close PowerShell, reopen, then run:" -ForegroundColor Cyan
Write-Host "    hermes" -ForegroundColor White
Write-Host ""
Write-Host "  Model: MiMo v2.5-pro (via Xiaomi)" -ForegroundColor Cyan
Write-Host ""
