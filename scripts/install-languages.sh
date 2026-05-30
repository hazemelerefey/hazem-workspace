#!/usr/bin/env bash
# Install Python 3, Node.js (nvm), Go, Rust
set -euo pipefail

CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
info()    { echo -e "${CYAN}[hazem]${NC} $1"; }
success() { echo -e "${GREEN}[hazem]${NC} $1"; }
warn()    { echo -e "${YELLOW}[hazem]${NC} $1"; }

# ── Python ──
info "Installing Python + pip + pipx + uv..."
sudo apt-get install -y -qq python3 python3-pip python3-venv pipx 2>/dev/null
if ! command -v uv &>/dev/null; then
    curl -fsSL https://astral.sh/uv/install.sh | bash 2>/dev/null || true
fi
success "Python $(python3 --version 2>&1) installed"

# ── Node.js via NVM ──
info "Installing Node.js via NVM..."
if [[ ! -d "$HOME/.nvm" ]]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash 2>/dev/null || true
fi
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
    nvm install --lts 2>/dev/null || true
    success "Node.js $(node --version 2>&1) installed via NVM"
else
    warn "NVM installation incomplete — install manually: https://github.com/nvm-sh/nvm"
fi

# ── Go ──
info "Installing Go..."
if ! command -v go &>/dev/null; then
    GO_VERSION=$(curl -fsSL https://go.dev/VERSION?m=text 2>/dev/null | head -1 || echo "go1.24.0")
    curl -fsSL "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz 2>/dev/null
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz 2>/dev/null
    rm -f /tmp/go.tar.gz
    # Add to PATH if not already
    if ! grep -q "/usr/local/go/bin" "$HOME/.exports" 2>/dev/null; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.exports"
    fi
    success "Go $(/usr/local/go/bin/go version 2>&1) installed"
else
    info "Go already installed: $(go version)"
fi

# ── Rust ──
info "Installing Rust via rustup..."
if ! command -v rustc &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>/dev/null || true
    source "$HOME/.cargo/env" 2>/dev/null || true
    success "Rust $(rustc --version 2>&1) installed"
else
    info "Rust already installed: $(rustc --version)"
fi

success "All languages installed!"
