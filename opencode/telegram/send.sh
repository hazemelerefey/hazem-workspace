#!/bin/bash
# Send a message via Telegram bot
source ~/.venv/bin/activate
python3 ~/.opencode/telegram/bot.py send "$@"
