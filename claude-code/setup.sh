#!/usr/bin/env bash
# ============================================================
#  Claude Code + Agent Router Setup — macOS / Linux
#  One command: curl -fsSL https://raw.githubusercontent.com/hazemelerefey/hazem-workspace/main/claude-code/setup.sh | bash
# ============================================================

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'

echo ""
echo -e "${CYAN}========================================${RESET}"
echo -e "${CYAN}  Claude Code Setup (Agent Router)${RESET}"
echo -e "${CYAN}========================================${RESET}"
echo ""

# --- API Key ---
AGENT_ROUTER_KEY="sk-m6uNqixfYkJrjpAIyirVcML6dXAR8FVPDVTB3O67MzZDFurI"

# Detect shell profile
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
else
    SHELL_PROFILE="$HOME/.profile"
fi

# ============================================
# 1. Install Claude Code
# ============================================
echo -e "\n--- Installing Claude Code ---"

if command -v claude &>/dev/null; then
    echo -e "${GREEN}[✓]${RESET} Claude Code found: $(claude --version 2>&1)"
else
    npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}[✓]${RESET} Claude Code installed"
fi

# ============================================
# 2. Claude Config
# ============================================
echo -e "\n--- Config ---"

CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

echo '{"model":"claude-opus-4-6"}' > "$CLAUDE_DIR/settings.json"
echo -e "${GREEN}[✓]${RESET} settings.json"

rm -rf "$CLAUDE_DIR/cache/"* "$CLAUDE_DIR/sessions/"* 2>/dev/null || true
echo -e "${GREEN}[✓]${RESET} Cache cleared"

# ============================================
# 3. Environment Variables
# ============================================
echo -e "\n--- Env Vars ---"

# Remove old entries
sed -i.bak '/# === Agent Router/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i.bak '/# === Xiaomi MiMo/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i.bak '/ANTHROPIC_BASE_URL/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i.bak '/ANTHROPIC_API_KEY/d' "$SHELL_PROFILE" 2>/dev/null || true
sed -i.bak '/ANTHROPIC_AUTH_TOKEN/d' "$SHELL_PROFILE" 2>/dev/null || true
rm -f "$SHELL_PROFILE.bak"

cat >> "$SHELL_PROFILE" << EOF

# === Agent Router (Claude Code) ===
export ANTHROPIC_BASE_URL="https://agentrouter.org/"
export ANTHROPIC_API_KEY="$AGENT_ROUTER_KEY"
EOF

echo -e "${GREEN}[✓]${RESET} Profile updated: $SHELL_PROFILE"

export ANTHROPIC_BASE_URL="https://agentrouter.org/"
export ANTHROPIC_API_KEY="$AGENT_ROUTER_KEY"
echo -e "${GREEN}[✓]${RESET} Env vars applied"

# ============================================
# 4. Restore Sessions
# ============================================
echo -e "\n--- Sessions ---"

SESSION_BACKUP="$HOME/hazem-workspace/claude-code/sessions"
if [ -d "$SESSION_BACKUP" ]; then
    mkdir -p "$CLAUDE_DIR/projects" "$CLAUDE_DIR/sessions"
    cp -r "$SESSION_BACKUP/projects/"* "$CLAUDE_DIR/projects/" 2>/dev/null && echo -e "${GREEN}[✓]${RESET} Projects restored" || echo -e "${YELLOW}[!]${RESET} No projects"
    cp -r "$SESSION_BACKUP/sessions/"* "$CLAUDE_DIR/sessions/" 2>/dev/null && echo -e "${GREEN}[✓]${RESET} Sessions restored" || echo -e "${YELLOW}[!]${RESET} No sessions"
else
    echo -e "${YELLOW}[!]${RESET} No backup found — clone repo first:"
    echo "    git clone https://github.com/hazemelerefey/hazem-workspace.git ~/hazem-workspace"
fi

# ============================================
# 5. Done
# ============================================
echo ""
echo -e "${GREEN}========================================${RESET}"
echo -e "${GREEN}  Claude Code Ready!${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo ""
echo -e "${CYAN}  Close terminal, reopen, then run:${RESET}"
echo "    claude"
echo ""
echo -e "${CYAN}  Switch models:${RESET}"
echo "    /model claude-opus-4-6"
echo "    /model claude-haiku-4-5-20251001"
echo ""
