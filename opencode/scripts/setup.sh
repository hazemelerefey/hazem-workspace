#!/usr/bin/env bash
# One-command setup: places all configs, restores sessions, ready to go
set -euo pipefail

REPO_DIR="$HOME/.opencode"
CYAN='\033[1;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo -e "${CYAN}══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  OpenCode — Full Setup${NC}"
echo -e "${CYAN}══════════════════════════════════════════════${NC}"
echo ""

# ── 1. OpenCode config with API keys ──
echo -e "${CYAN}[1/4]${NC} Installing OpenCode config..."
mkdir -p "$HOME/.config/opencode"
cp "$REPO_DIR/configs/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
echo -e "  ${GREEN}✅${NC} Config placed at ~/.config/opencode/opencode.jsonc"

# ── 2. Git config + credentials (for push/pull on any machine) ──
echo -e "${CYAN}[2/4]${NC} Setting up Git..."
cp "$REPO_DIR/configs/.gitconfig" "$HOME/.gitconfig"
cp "$REPO_DIR/configs/.git-credentials" "$HOME/.git-credentials"
chmod 600 "$HOME/.git-credentials"
echo -e "  ${GREEN}✅${NC} Git configured as $(git config user.name)"

# ── 3. Restore sessions ──
echo -e "${CYAN}[3/4]${NC} Restoring sessions..."
mkdir -p "$HOME/.local/share/opencode"
if [ -f "$REPO_DIR/sessions/opencode.db" ]; then
    cp "$REPO_DIR/sessions/opencode.db" "$HOME/.local/share/opencode/opencode.db"
    echo -e "  ${GREEN}✅${NC} Sessions restored ($(du -h "$REPO_DIR/sessions/opencode.db" | cut -f1))"
fi
if [ -f "$REPO_DIR/sessions/quota-tracker.json" ]; then
    cp "$REPO_DIR/sessions/quota-tracker.json" "$HOME/.local/share/opencode/quota-tracker.json"
    echo -e "  ${GREEN}✅${NC} Quota tracker restored"
fi

# ── 4. Done ──
echo -e "${CYAN}[4/4]${NC} Setup complete!"
echo ""
echo -e "${GREEN}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  All done! Just run: opencode${NC}"
echo -e "${GREEN}══════════════════════════════════════════════${NC}"
echo ""
