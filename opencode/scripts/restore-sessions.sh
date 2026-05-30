#!/usr/bin/env bash
# Restore OpenCode sessions from repo to the correct local path
set -euo pipefail

REPO_SESSIONS="$HOME/.opencode/sessions"
LOCAL_OPENCODE_DIR="$HOME/.local/share/opencode"

echo "=== Restoring OpenCode sessions ==="

# Create local directory if needed
mkdir -p "$LOCAL_OPENCODE_DIR"

# Restore database
if [ -f "$REPO_SESSIONS/opencode.db" ]; then
    # Stop OpenCode if running
    echo "Copying session database..."
    cp "$REPO_SESSIONS/opencode.db" "$LOCAL_OPENCODE_DIR/opencode.db"
    echo "  ✅ Sessions restored ($(du -h "$REPO_SESSIONS/opencode.db" | cut -f1))"
else
    echo "  ⚠️  No session database found in repo"
fi

# Restore quota tracker
if [ -f "$REPO_SESSIONS/quota-tracker.json" ]; then
    mkdir -p "$LOCAL_OPENCODE_DIR"
    cp "$REPO_SESSIONS/quota-tracker.json" "$LOCAL_OPENCODE_DIR/quota-tracker.json"
    echo "  ✅ Quota tracker restored"
fi

echo ""
echo "Done! OpenCode will now have all your sessions."
