#!/usr/bin/env bash
# Install CLI tools: bat, ripgrep, fd, fzf, tmux, lazygit, jq, htop
set -euo pipefail

CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
info()    { echo -e "${CYAN}[hazem]${NC} $1"; }
success() { echo -e "${GREEN}[hazem]${NC} $1"; }
warn()    { echo -e "${YELLOW}[hazem]${NC} $1"; }

info "Installing CLI tools..."

sudo apt-get install -y -qq \
    bat ripgrep fd-find fzf tmux jq htop tree \
    2>/dev/null || warn "Some packages may not have installed"

# lazygit
if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" 2>/dev/null | grep '"tag_name"' | cut -d'"' -f4)
    LAZYGIT_VERSION="${LAZYGIT_VERSION:-v0.47.2}"
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz" -o /tmp/lazygit.tar.gz 2>/dev/null
    sudo tar -C /usr/local/bin -xzf /tmp/lazygit.tar.gz lazygit 2>/dev/null
    rm -f /tmp/lazygit.tar.gz
    success "lazygit installed"
fi

# Create aliases for batcat → bat, fdfind → fd
mkdir -p "$HOME/.local/bin"
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

success "CLI tools installed!"
info "  bat, ripgrep (rg), fd, fzf, tmux, lazygit, jq, htop, tree"
