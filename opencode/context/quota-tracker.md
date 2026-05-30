<!-- Context: quota-tracker | Priority: medium | Version: 1.0 -->
# Quota Tracker

A server-side plugin at `.opencode/plugin/opencode-quota-tracker.ts` automatically tracks model token usage, costs, and quota.

## How It Works

Every time an assistant message completes, the plugin captures:
- Input/output/reasoning tokens
- Cache read/write tokens
- Dollar cost
- Model & provider IDs

Data persists at `~/.local/share/opencode/quota-tracker.json`.

## How to View Usage

**Via command:** The user can run `/quota` at any time. Read the tracker file and present a clear summary:
- Total tokens (input + output)
- Total cost
- Per-model breakdown (tokens, cost, messages)
- Number of sessions tracked

**Via conversation:** If the user asks "what's my usage?" or "check my quota", read the tracker file and summarize.

## Reset

The `/quota.reset` command clears all tracked data. Confirm with the user before proceeding.
