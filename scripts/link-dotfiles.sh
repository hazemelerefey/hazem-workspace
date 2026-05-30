#!/usr/bin/env bash
# Symlink all dotfiles from hazem-workspace to ~/
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CYAN='\033[1;36m'
GREEN='\033[0;32m'
NC='\033[0m'
info()  { echo -e "${CYAN}[hazem]${NC} $1"; }
success() { echo -e "${GREEN}[hazem]${NC} $1"; }

info "Linking dotfiles..."

# ZSH config
if [[ -f "$REPO_DIR/shell/.zshrc" ]]; then
    ln -sf "$REPO_DIR/shell/.zshrc" "$HOME/.zshrc"
    success "  ~/.zshrc → hazem-workspace/shell/.zshrc"
fi

# Bash fallback
if [[ -f "$REPO_DIR/shell/.bashrc" ]]; then
    ln -sf "$REPO_DIR/shell/.bashrc" "$HOME/.bashrc"
    success "  ~/.bashrc → hazem-workspace/shell/.bashrc"
fi

# Aliases, exports, functions (sourced by .zshrc)
if [[ -f "$REPO_DIR/shell/.aliases" ]]; then
    ln -sf "$REPO_DIR/shell/.aliases" "$HOME/.aliases"
fi
if [[ -f "$REPO_DIR/shell/.exports" ]]; then
    ln -sf "$REPO_DIR/shell/.exports" "$HOME/.exports"
fi
if [[ -f "$REPO_DIR/shell/.functions" ]]; then
    ln -sf "$REPO_DIR/shell/.functions" "$HOME/.functions"
fi

# Tmux
if [[ -f "$REPO_DIR/configs/.tmux.conf" ]]; then
    ln -sf "$REPO_DIR/configs/.tmux.conf" "$HOME/.tmux.conf"
    success "  ~/.tmux.conf → hazem-workspace/configs/.tmux.conf"
fi

# Ensure ~/.local/bin is in PATH
mkdir -p "$HOME/.local/bin"

success "Dotfiles linked!"
