#!/usr/bin/env bash
# =============================================================================
# Hazem Workspace — Universal Setup
# =============================================================================
# Usage:
#   bash setup.sh          → Shows help
#   bash setup.sh env      → Install environment (ZSH, languages, tools, Docker)
#   bash setup.sh opencode → Install OpenCode configs + sessions
#   bash setup.sh hermes   → Placeholder
#   bash setup.sh openclaw → Placeholder
#   bash setup.sh all      → Install everything
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${CYAN}[hazem]${NC} $1"; }
success() { echo -e "${GREEN}[hazem]${NC} $1"; }
warn()    { echo -e "${YELLOW}[hazem]${NC} $1"; }
error()   { echo -e "${RED}[hazem]${NC} ERROR: $1" >&2; exit 1; }
section() { echo ""; echo -e "${BOLD}${CYAN}── $1 ──${NC}"; }

show_help() {
    echo ""
    echo -e "${BOLD}Hazem Workspace — Setup${NC}"
    echo ""
    echo "Usage: bash setup.sh <component>"
    echo ""
    echo "Components:"
    echo "  env         Install environment (ZSH, Oh My Zsh, languages, tools, Docker)"
    echo "  opencode    Install OpenCode (configs, agents, skills, sessions)"
    echo "  hermes      (planned)"
    echo "  openclaw    (planned)"
    echo "  all         Install everything (env + opencode)"
    echo ""
    echo "Examples:"
    echo "  bash setup.sh all"
    echo "  bash setup.sh env"
    echo "  bash setup.sh opencode"
    echo ""
}

# ── Pre-flight ───────────────────────────────────────────────────────────────

check_prerequisites() {
    if [[ "$(uname)" != "Linux" ]]; then
        error "This setup is designed for Ubuntu Linux / WSL."
    fi
    if ! command -v sudo &>/dev/null; then
        error "sudo is required but not installed."
    fi
    if ! command -v apt-get &>/dev/null; then
        error "apt-get is required (Ubuntu/Debian)."
    fi
}

# ── Components ───────────────────────────────────────────────────────────────

install_env() {
    section "Installing Environment"

    info "Step 1/6: Installing core (ZSH + Oh My Zsh + Powerlevel10k)..."
    bash "$REPO_DIR/scripts/install-core.sh"

    info "Step 2/6: Installing languages (Python, Node, Go, Rust)..."
    bash "$REPO_DIR/scripts/install-languages.sh"

    info "Step 3/6: Installing CLI tools (bat, rg, fd, fzf, tmux, lazygit, jq)..."
    bash "$REPO_DIR/scripts/install-tools.sh"

    info "Step 4/6: Installing Docker..."
    bash "$REPO_DIR/scripts/install-docker.sh"

    info "Step 5/6: Linking dotfiles..."
    bash "$REPO_DIR/scripts/link-dotfiles.sh"

    info "Step 6/6: Setting ZSH as default shell..."
    if [[ "$SHELL" != *"zsh" ]]; then
        if command -v zsh &>/dev/null; then
            chsh -s "$(command -v zsh)" 2>/dev/null || warn "Could not change shell. Run: chsh -s $(command -v zsh)"
            success "Default shell set to ZSH (restart terminal to apply)"
        fi
    else
        success "ZSH is already the default shell"
    fi

    success "Environment setup complete!"
    info "Restart your terminal or run: exec zsh"
}

install_opencode() {
    section "Installing OpenCode"

    local OPENCODE_TARGET="$HOME/.opencode"
    local CONFIG_TARGET="$HOME/.config/opencode"
    local SESSIONS_TARGET="$HOME/.local/share/opencode"

    if [[ -d "$OPENCODE_TARGET" ]]; then
        warn "OpenCode already installed at $OPENCODE_TARGET"
        info "To reinstall, remove it first: rm -rf $OPENCODE_TARGET"
        return
    fi

    info "Step 1/4: Linking OpenCode config to ~/.opencode..."
    ln -sf "$REPO_DIR/opencode" "$OPENCODE_TARGET"
    success "Linked to $OPENCODE_TARGET"

    info "Step 2/4: Placing OpenCode config at $CONFIG_TARGET..."
    mkdir -p "$CONFIG_TARGET"
    if [[ -f "$REPO_DIR/configs/opencode.jsonc" ]]; then
        cp "$REPO_DIR/configs/opencode.jsonc" "$CONFIG_TARGET/opencode.jsonc"
        success "Config placed"
    fi

    info "Step 3/4: Restoring sessions..."
    bash "$REPO_DIR/scripts/restore-sessions.sh"

    info "Step 4/4: Placing git config..."
    if [[ -f "$REPO_DIR/configs/.gitconfig" ]]; then
        cp "$REPO_DIR/configs/.gitconfig" "$HOME/.gitconfig"
        success "Git config placed"
    fi
    if [[ -f "$REPO_DIR/configs/.git-credentials" ]]; then
        cp "$REPO_DIR/configs/.git-credentials" "$HOME/.git-credentials"
        chmod 600 "$HOME/.git-credentials"
        success "Git credentials placed"
    fi

    success "OpenCode setup complete!"
    info "Run: opencode"
}

install_hermes() {
    section "Hermes"
    echo ""
    info "Hermes integration is planned for a future update."
    info "Check back later at: https://github.com/hazemelerefey/hazem-workspace"
    echo ""
}

install_openclaw() {
    section "OpenClaw"
    echo ""
    info "OpenClaw integration is planned for a future update."
    info "Check back later at: https://github.com/hazemelerefey/hazem-workspace"
    echo ""
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
    local component="${1:-help}"

    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  Hazem Workspace — Setup${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo ""

    case "$component" in
        env)
            check_prerequisites
            install_env
            ;;
        opencode)
            install_opencode
            ;;
        hermes)
            install_hermes
            ;;
        openclaw)
            install_openclaw
            ;;
        all)
            check_prerequisites
            install_env
            echo ""
            install_opencode
            echo ""
            section "All Components Installed"
            success "Everything is set up!"
            info "Restart your terminal or run: exec zsh"
            info "Then run: opencode"
            ;;
        help|--help|-h|"")
            show_help
            ;;
        *)
            error "Unknown component: $component"
            echo "Use: bash setup.sh help"
            ;;
    esac
}

main "$@"
