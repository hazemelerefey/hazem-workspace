#!/usr/bin/env bash
# Install ZSH + Oh My Zsh + Powerlevel10k + plugins
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_DIR/scripts/colors.sh" 2>/dev/null || true

CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
info()    { echo -e "${CYAN}[hazem]${NC} $1"; }
success() { echo -e "${GREEN}[hazem]${NC} $1"; }
warn()    { echo -e "${YELLOW}[hazem]${NC} $1"; }

info "Installing ZSH..."
sudo apt-get update -qq && sudo apt-get install -y -qq zsh curl git 2>/dev/null
success "ZSH installed ($(zsh --version))"

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || true
    success "Oh My Zsh installed"
else
    info "Oh My Zsh already installed"
fi

# Powerlevel10k theme
if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
    info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" 2>/dev/null || true
    success "Powerlevel10k installed"
else
    info "Powerlevel10k already installed"
fi

# Plugins: zsh-autosuggestions + zsh-syntax-highlighting
if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
    info "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" 2>/dev/null || true
fi
if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
    info "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" 2>/dev/null || true
fi
success "Plugins installed"

# ── Link hazem-workspace dotfiles (overrides Oh My Zsh default .zshrc) ──
info "Linking hazem-workspace dotfiles..."
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -d "$REPO_DIR/shell" ]]; then
    ln -sf "$REPO_DIR/shell/.zshrc" "$HOME/.zshrc"
    ln -sf "$REPO_DIR/shell/.aliases" "$HOME/.aliases"
    ln -sf "$REPO_DIR/shell/.exports" "$HOME/.exports"
    ln -sf "$REPO_DIR/shell/.functions" "$HOME/.functions"
    success "Dotfiles linked (Powerlevel10k theme + aliases + exports)"
fi

success "Core setup complete!"
info "Restart your terminal or run: exec zsh"
