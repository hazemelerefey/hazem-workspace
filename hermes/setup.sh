#!/usr/bin/env bash
# ============================================================
#  Hermes Agent Setup — macOS / Linux
#  One command: curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/hermes/setup.sh | bash
# ============================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'

echo ""
echo -e "${CYAN}========================================${RESET}"
echo -e "${CYAN}  Hermes Agent Setup${RESET}"
echo -e "${CYAN}========================================${RESET}"
echo ""

# --- API Key ---
MIMO_KEY="sk-sww798prqp55b7c4yhbsstumszvwza48jn1b7fhq8gaieow3"

# ============================================
# 1. Check Python
# ============================================
echo -e "\n--- Python ---"

if command -v python3 &>/dev/null; then
    echo -e "${GREEN}[✓]${RESET} Python3 found: $(python3 --version 2>&1)"
    PY="python3"
elif command -v python &>/dev/null; then
    echo -e "${GREEN}[✓]${RESET} Python found: $(python --version 2>&1)"
    PY="python"
else
    echo -e "${GREEN}[✗]${RESET} Python not found. Install python3 then re-run."
    exit 1
fi

# ============================================
# 2. Install Hermes Agent
# ============================================
echo -e "\n--- Hermes Agent ---"

if command -v hermes &>/dev/null; then
    echo -e "${GREEN}[✓]${RESET} Hermes found: $(hermes --version 2>&1 | head -1)"
else
    echo -e "${YELLOW}[*]${RESET} Installing Hermes Agent..."
    $PY -m pip install hermes-agent 2>/dev/null || pip install hermes-agent
    echo -e "${GREEN}[✓]${RESET} Hermes installed"
fi

# ============================================
# 3. Initialize Config
# ============================================
echo -e "\n--- Config ---"

HERMES_CONFIG="$HOME/.config/hermes/config.yaml"

if [ ! -f "$HERMES_CONFIG" ]; then
    echo -e "${YELLOW}[*]${RESET} First run — generating default config..."
    hermes --version 2>/dev/null || true
fi

if [ -f "$HERMES_CONFIG" ]; then
    sed -i.bak 's/default:.*/default: mimo-v2.5-pro/' "$HERMES_CONFIG"
    sed -i.bak 's/provider:.*/provider: xiaomi/' "$HERMES_CONFIG"
    rm -f "$HERMES_CONFIG.bak"
    echo -e "${GREEN}[✓]${RESET} Config updated (MiMo v2.5-pro)"
else
    echo -e "${YELLOW}[!]${RESET} Config not found — run 'hermes' once to generate it"
fi

# ============================================
# 4. Restore Skills
# ============================================
echo -e "\n--- Skills ---"

SKILLS_BACKUP="$HOME/hazem-workspace/hermes/skills"
SKILLS_DIR="$HOME/.config/hermes/skills"

if [ -d "$SKILLS_BACKUP" ]; then
    mkdir -p "$SKILLS_DIR"
    cp -r "$SKILLS_BACKUP/"* "$SKILLS_DIR/" 2>/dev/null && echo -e "${GREEN}[✓]${RESET} Skills restored" || echo -e "${YELLOW}[*]${RESET} No skills to restore"
else
    echo -e "${YELLOW}[*]${RESET} No skills backup — using defaults"
fi

# ============================================
# 5. Done
# ============================================
echo ""
echo -e "${GREEN}========================================${RESET}"
echo -e "${GREEN}  Hermes Agent Ready!${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo ""
echo -e "${CYAN}  Close terminal, reopen, then run:${RESET}"
echo "    hermes"
echo ""
echo -e "${CYAN}  Model: MiMo v2.5-pro (via Xiaomi)${RESET}"
echo ""
