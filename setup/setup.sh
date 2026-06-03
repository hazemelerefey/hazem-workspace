#!/usr/bin/env bash
# ============================================================
#  Hazem's Full Dev Environment Setup — macOS / Linux
#  One command: curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/setup/setup.sh | bash
# ============================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; RESET='\033[0m'

log()  { echo -e "${GREEN}[✓]${RESET} $1"; }
warn() { echo -e "${YELLOW}[!]${RESET} $1"; }
err()  { echo -e "${RED}[✗]${RESET} $1"; }

echo ""
echo -e "${CYAN}========================================${RESET}"
echo -e "${CYAN}  Hazem Dev Environment Setup (Unix)${RESET}"
echo -e "${CYAN}========================================${RESET}"
echo ""

# --- Config (edit these when API keys change) ---
AGENT_ROUTER_KEY="sk-2DiZntY7Qu5yGz5PCIyromiv9ABoXpW5mtyawyrYyL4ZWfC6"
MIMO_KEY="sk-sww798prqp55b7c4yhbsstumszvwza48jn1b7fhq8gaieow3"
COMPOSIO_KEY="ak_HiyqXrz8dU_ijR35vesS"
COMPOSIO_URL="https://backend.composio.dev/tool_router/trs_XKI7uBm-Oo1q/mcp"

# Detect shell profile
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
else
    SHELL_PROFILE="$HOME/.profile"
fi

# ============================================
# 1. Prerequisites Check
# ============================================
echo -e "\n--- Prerequisites ---"

if command -v node &>/dev/null; then
    log "Node.js found: $(node --version)"
else
    err "Node.js not found. Install from https://nodejs.org then re-run."
    exit 1
fi

if command -v git &>/dev/null; then
    log "Git found: $(git --version)"
else
    err "Git not found. Install git then re-run."
    exit 1
fi

if command -v npm &>/dev/null; then
    log "npm found: $(npm --version)"
else
    err "npm not found. Reinstall Node.js."
    exit 1
fi

# ============================================
# 2. Install Claude Code
# ============================================
echo -e "\n--- Claude Code ---"

if command -v claude &>/dev/null; then
    log "Claude Code found: $(claude --version 2>&1)"
else
    warn "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    log "Claude Code installed"
fi

# ============================================
# 3. Install Hermes Agent
# ============================================
echo -e "\n--- Hermes Agent ---"

if command -v hermes &>/dev/null; then
    log "Hermes found: $(hermes --version 2>&1 | head -1)"
else
    warn "Installing Hermes Agent..."
    pip install hermes-agent 2>/dev/null || pip3 install hermes-agent
    log "Hermes installed"
fi

# ============================================
# 4. Claude Code Config
# ============================================
echo -e "\n--- Claude Code Config ---"

CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

cat > "$CLAUDE_DIR/settings.json" << 'SETTINGS'
{"model":"claude-opus-4-6"}
SETTINGS
log "settings.json written"

rm -rf "$CLAUDE_DIR/cache/"* "$CLAUDE_DIR/sessions/"* 2>/dev/null || true
log "Cache cleared"

# ============================================
# 5. Shell Profile
# ============================================
echo -e "\n--- Shell Profile ---"

# Remove old Agent Router / MiMo entries
sed -i.bak '/# === Agent Router/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i.bak '/ANTHROPIC_BASE_URL/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i.bak '/ANTHROPIC_API_KEY/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i.bak '/ANTHROPIC_AUTH_TOKEN/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i.bak '/# === Xiaomi MiMo/d' "$SHELL_PROFILE" 2>/dev/null || true
rm -f "$SHELL_PROFILE.bak"

cat >> "$SHELL_PROFILE" << PROFILE

# === Agent Router (Claude Code) ===
export ANTHROPIC_BASE_URL="https://agentrouter.org/"
export ANTHROPIC_API_KEY="$AGENT_ROUTER_KEY"
PROFILE

log "Shell profile updated: $SHELL_PROFILE"

# Apply to current session
export ANTHROPIC_BASE_URL="https://agentrouter.org/"
export ANTHROPIC_API_KEY="$AGENT_ROUTER_KEY"
log "Env vars applied to current session"

# ============================================
# 6. Hermes Config
# ============================================
echo -e "\n--- Hermes Config ---"

HERMES_CONFIG="$HOME/.config/hermes/config.yaml"
if [ -f "$HERMES_CONFIG" ]; then
    sed -i.bak 's/default:.*/default: mimo-v2.5-pro/' "$HERMES_CONFIG" 2>/dev/null || true
    rm -f "$HERMES_CONFIG.bak"
    log "Hermes config updated"
else
    warn "Hermes config not found — run 'hermes' once to generate it"
fi

# ============================================
# 7. Restore Claude Sessions
# ============================================
echo -e "\n--- Session Restore ---"

SESSION_BACKUP="$HOME/hazem-workspace/claude-code/sessions"
if [ -d "$SESSION_BACKUP" ]; then
    mkdir -p "$CLAUDE_DIR/projects" "$CLAUDE_DIR/sessions"
    cp -r "$SESSION_BACKUP/projects/"* "$CLAUDE_DIR/projects/" 2>/dev/null && log "Projects restored" || warn "No projects to restore"
    cp -r "$SESSION_BACKUP/sessions/"* "$CLAUDE_DIR/sessions/" 2>/dev/null && log "Sessions restored" || warn "No sessions to restore"
else
    warn "No session backup found — skipping"
    warn "Clone first: git clone https://github.com/hazemelerefey/hazem-workspace.git ~/hazem-workspace"
fi

# ============================================
# 8. Verify
# ============================================
echo -e "\n--- Verification ---"

echo "  Node.js:        $(node --version 2>&1)"
echo "  npm:            $(npm --version 2>&1)"
echo "  Git:            $(git --version 2>&1)"
echo "  Claude Code:    $(claude --version 2>&1)"
echo "  Hermes:         $(hermes --version 2>&1 | head -1)"
echo "  ANTHROPIC_URL:  $ANTHROPIC_BASE_URL"
echo "  ANTHROPIC_KEY:  ${ANTHROPIC_API_KEY:0:8}..."

echo ""
echo -e "${GREEN}========================================${RESET}"
echo -e "${GREEN}  Setup Complete!${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo ""
echo -e "${CYAN}Next steps:${RESET}"
echo "  1. Close and reopen your terminal"
echo "  2. Run: claude          (launch Claude Code)"
echo "  3. Run: hermes          (launch Hermes Agent)"
echo ""
echo -e "${CYAN}Switch models in Claude Code:${RESET}"
echo "  /model claude-opus-4-6"
echo "  /model claude-haiku-4-5-20251001"
echo ""
