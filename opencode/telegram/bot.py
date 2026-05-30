#!/usr/bin/env python3
"""
Telegram Bot for OpenAgent
- Listens for messages from authorized user
- Writes incoming messages to inbox/ for processing
- Can send messages via CLI
"""

import sys
import os
import json
import asyncio
import signal
from pathlib import Path
from datetime import datetime

from telegram import Bot
from telegram.error import TelegramError

# Config
TOKEN = "8929393192:AAFRrWTBZGGRuUI4CWMQNIh0tDDW9Mn0MSc"
USER_ID = 1162042737
BASE_DIR = Path(os.path.expanduser("~/.opencode/telegram"))
INBOX_DIR = BASE_DIR / "inbox"
OUTBOX_DIR = BASE_DIR / "outbox"

async def send_message(text: str) -> dict:
    """Send a message to the authorized user."""
    bot = Bot(token=TOKEN)
    try:
        msg = await bot.send_message(chat_id=USER_ID, text=text)
        return {"success": True, "message_id": msg.message_id}
    except TelegramError as e:
        return {"success": False, "error": str(e)}

async def poll_messages():
    """Poll for new messages and save to inbox."""
    bot = Bot(token=TOKEN)
    last_update_id = 0
    
    # Load last processed update ID
    state_file = BASE_DIR / "state.json"
    if state_file.exists():
        try:
            state = json.loads(state_file.read_text())
            last_update_id = state.get("last_update_id", 0)
        except:
            pass

    INBOX_DIR.mkdir(parents=True, exist_ok=True)

    try:
        updates = await bot.get_updates(offset=last_update_id + 1, timeout=30)
        for update in updates:
            if update.update_id > last_update_id:
                last_update_id = update.update_id
            
            if update.message and update.message.from_user.id == USER_ID:
                msg_data = {
                    "message_id": update.message.message_id,
                    "text": update.message.text,
                    "date": update.message.date.isoformat(),
                    "received_at": datetime.now().isoformat()
                }
                
                # Save to inbox
                inbox_file = INBOX_DIR / f"{update.message.message_id}.json"
                inbox_file.write_text(json.dumps(msg_data, indent=2))
                
                # Acknowledge receipt
                await bot.send_message(
                    chat_id=USER_ID,
                    text=f"✅ Received: \"{update.message.text[:50]}{'...' if len(update.message.text) > 50 else ''}\""
                )

        # Save state
        state_file.write_text(json.dumps({"last_update_id": last_update_id}))
        
    except TelegramError as e:
        return {"error": str(e)}
    
    return {"status": "ok", "updates_processed": 0}

async def main():
    if len(sys.argv) > 1:
        if sys.argv[1] == "send":
            text = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else ""
            if text:
                result = await send_message(text)
                print(json.dumps(result))
            else:
                print(json.dumps({"error": "No message text provided"}))
        elif sys.argv[1] == "poll":
            result = await poll_messages()
        elif sys.argv[1] == "listen":
            print("🔴 Listening for messages... (Ctrl+C to stop)")
            while True:
                await poll_messages()
                await asyncio.sleep(2)
        else:
            print(json.dumps({"error": "Unknown command. Use: send, poll, listen"}))
    else:
        print("Usage: bot.py [send <text> | poll | listen]")

if __name__ == "__main__":
    asyncio.run(main())
