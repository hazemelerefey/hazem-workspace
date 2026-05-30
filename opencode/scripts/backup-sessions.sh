#!/usr/bin/env bash
# Backup local OpenCode sessions into the repo (run before committing)
set -euo pipefail

REPO_SESSIONS="$HOME/.opencode/sessions"
LOCAL_OPENCODE_DIR="$HOME/.local/share/opencode"

echo "=== Backing up OpenCode sessions to repo ==="

mkdir -p "$REPO_SESSIONS"

# Backup database
if [ -f "$LOCAL_OPENCODE_DIR/opencode.db" ]; then
    cp "$LOCAL_OPENCODE_DIR/opencode.db" "$REPO_SESSIONS/opencode.db"
    echo "  ✅ Database backed up ($(du -h "$REPO_SESSIONS/opencode.db" | cut -f1))"
else
    echo "  ⚠️  No local database found at $LOCAL_OPENCODE_DIR/opencode.db"
fi

# Backup quota tracker
if [ -f "$LOCAL_OPENCODE_DIR/quota-tracker.json" ]; then
    cp "$LOCAL_OPENCODE_DIR/quota-tracker.json" "$REPO_SESSIONS/quota-tracker.json"
    echo "  ✅ Quota tracker backed up"
fi

echo ""
echo "Done! Now commit and push:"
echo "  cd ~/.opencode && git add sessions/ && git commit -m 'Update sessions' && git push"
