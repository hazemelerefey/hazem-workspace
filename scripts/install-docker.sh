#!/usr/bin/env bash
# Install Docker Engine + Docker Compose for Ubuntu/WSL
set -euo pipefail

CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
info()    { echo -e "${CYAN}[hazem]${NC} $1"; }
success() { echo -e "${GREEN}[hazem]${NC} $1"; }
warn()    { echo -e "${YELLOW}[hazem]${NC} $1"; }

if command -v docker &>/dev/null; then
    info "Docker already installed ($(docker --version))"
    if docker info &>/dev/null; then
        success "Docker daemon is running"
        return 0
    else
        warn "Docker daemon is not running — start Docker Desktop"
        return 0
    fi
fi

info "Installing Docker..."
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sudo sh /tmp/get-docker.sh 2>/dev/null
sudo usermod -aG docker "$USER" 2>/dev/null || true
rm -f /tmp/get-docker.sh

success "Docker installed! Log out and back in for group changes to take effect."
info "Or run: newgrp docker"
