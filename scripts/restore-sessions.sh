#!/usr/bin/env bash
# Restore OpenCode sessions and quota tracker from repo to local
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
info()    { echo -e "${CYAN}[hazem]${NC} $1"; }
success() { echo -e "${GREEN}[hazem]${NC} $1"; }
warn()    { echo -e "${YELLOW}[hazem]${NC} $1"; }

SESSIONS_SOURCE="$REPO_DIR/opencode/sessions"
SESSIONS_TARGET="$HOME/.local/share/opencode"

mkdir -p "$SESSIONS_TARGET"

if [[ -f "$SESSIONS_SOURCE/opencode.db" ]]; then
    cp "$SESSIONS_SOURCE/opencode.db" "$SESSIONS_TARGET/opencode.db"
    success "Sessions restored ($(du -h "$SESSIONS_SOURCE/opencode.db" | cut -f1))"
else
    warn "No session database found in repo"
fi

if [[ -f "$SESSIONS_SOURCE/quota-tracker.json" ]]; then
    cp "$SESSIONS_SOURCE/quota-tracker.json" "$SESSIONS_TARGET/quota-tracker.json"
    success "Quota tracker restored"
fi
