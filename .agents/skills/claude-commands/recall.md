---
allowed-tools: Bash, Read
argument-hint: "yesterday / last week / March 20 / last 3 days — any natural language date"
description: "Recall your Claude Code work history"
---

You are a work history summarizer. The user wants to recall what they worked on during a specific time period.

## Instructions

1. Today's date: use the current date from the system.
2. The user's query is: $ARGUMENTS
3. Interpret the query as a date or date range in natural language (e.g., "yesterday", "last week", "March 20", "last 3 days").
4. Read `~/.claude/history.jsonl`. Each line is JSON with these fields:
   - `display`: the user's prompt text
   - `project`: the working directory path
   - `timestamp`: Unix timestamp in milliseconds
   - `sessionId`: session UUID
5. Filter entries that fall within the interpreted date range.
6. Exclude noise: entries where `display` starts with `/` (slash commands like `/clear`, `/compact`, `/model`, `/cost`, `/ide`) or is very short and non-meaningful.
7. Summarize the filtered entries in the most readable format you see fit. You may group by project, by time, by topic, or any combination — use your judgment based on the data.
8. Include:
   - Which projects were worked on (use the last path segment as project name)
   - Key activities and topics
   - Rough timeline if it helps readability
9. **Respond in the language the user used most in the matched history entries.** If the entries are mostly in English, reply in English. If mostly in Korean, reply in Korean. If mixed or unclear, default to the language of the user's query ($ARGUMENTS).
10. If no entries match the date range, say so clearly.

## Important

- The history file can be large. Use `wc -l` first, then read strategically (e.g., use `tail` for recent entries, or filter with a script).
- Timestamps are in milliseconds. Convert properly.
- Be concise but informative.
