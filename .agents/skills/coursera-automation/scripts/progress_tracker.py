#!/usr/bin/env python3
"""
Coursera Progress Tracker
Tracks and reports course completion progress.

Usage:
  python progress_tracker.py init <course_name>          - Initialize tracking for a course
  python progress_tracker.py update <course> <section> <status> - Update section status
  python progress_tracker.py report <course_name>        - Generate progress report
  python progress_tracker.py summary <course_name>       - Generate final summary
  python progress_tracker.py list                        - List all tracked courses

Status values: completed, skipped, failed, in_progress
"""

import json
import sys
import os
from datetime import datetime
from pathlib import Path

# Fix Windows console encoding for emoji support
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')

PROGRESS_DIR = Path.home() / ".coursera-progress"

def get_progress_file(course_name):
    safe_name = course_name.replace(" ", "_").lower()
    return PROGRESS_DIR / f"{safe_name}.json"

def init_course(course_name):
    PROGRESS_DIR.mkdir(exist_ok=True)
    data = {
        "course": course_name,
        "started_at": datetime.now().isoformat(),
        "last_updated": datetime.now().isoformat(),
        "modules": {},
        "sections_completed": 0,
        "sections_skipped": 0,
        "sections_failed": 0,
        "quizzes_passed": 0,
        "quizzes_failed": 0,
        "videos_completed": 0,
        "errors": []
    }
    path = get_progress_file(course_name)
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
    print(f"✅ Tracking initialized: {course_name}")
    print(f"📁 Progress file: {path}")

def load_progress(course_name):
    path = get_progress_file(course_name)
    if not path.exists():
        print(f"❌ No progress found for: {course_name}")
        print(f"   Run: python progress_tracker.py init \"{course_name}\"")
        sys.exit(1)
    with open(path) as f:
        return json.load(f)

def save_progress(course_name, data):
    data["last_updated"] = datetime.now().isoformat()
    path = get_progress_file(course_name)
    with open(path, "w") as f:
        json.dump(data, f, indent=2)

def update_section(course_name, section, status):
    data = load_progress(course_name)
    data["modules"][section] = {
        "status": status,
        "timestamp": datetime.now().isoformat()
    }
    if status == "completed":
        data["sections_completed"] += 1
    elif status == "skipped":
        data["sections_skipped"] += 1
    elif status == "failed":
        data["sections_failed"] += 1
    save_progress(course_name, data)
    print(f"✅ Updated: {section} -> {status}")

def log_error(course_name, section, error_msg):
    data = load_progress(course_name)
    data["errors"].append({
        "timestamp": datetime.now().isoformat(),
        "section": section,
        "error": error_msg
    })
    save_progress(course_name, data)
    print(f"⚠️ Error logged for {section}: {error_msg}")

def report(course_name):
    data = load_progress(course_name)
    total = data["sections_completed"] + data["sections_skipped"] + data["sections_failed"]
    print(f"\n{'='*50}")
    print(f"📊 {data['course']}")
    print(f"{'='*50}")
    print(f"  Sections completed: {data['sections_completed']}")
    print(f"  Sections skipped:   {data['sections_skipped']}")
    print(f"  Sections failed:    {data['sections_failed']}")
    print(f"  Videos completed:   {data['videos_completed']}")
    print(f"  Quizzes passed:     {data['quizzes_passed']}")
    print(f"  Quizzes failed:     {data['quizzes_failed']}")
    if data["errors"]:
        print(f"  ⚠️ Errors:          {len(data['errors'])}")
    print(f"  Started:            {data['started_at']}")
    print(f"  Last updated:       {data['last_updated']}")
    print(f"{'='*50}")

def list_courses():
    PROGRESS_DIR.mkdir(exist_ok=True)
    files = list(PROGRESS_DIR.glob("*.json"))
    if not files:
        print("No courses being tracked.")
        return
    print(f"\n📚 Tracking {len(files)} course(s):")
    for f in files:
        with open(f) as fh:
            data = json.load(fh)
        total = data["sections_completed"] + data["sections_skipped"] + data["sections_failed"]
        print(f"  • {data['course']} — {data['sections_completed']} sections done, last updated: {data['last_updated']}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    action = sys.argv[1]
    
    if action == "init":
        if len(sys.argv) < 3:
            print("Usage: progress_tracker.py init <course_name>")
            sys.exit(1)
        init_course(" ".join(sys.argv[2:]))
    
    elif action == "update":
        if len(sys.argv) < 5:
            print("Usage: progress_tracker.py update <course> <section> <status>")
            print("Status: completed, skipped, failed, in_progress")
            sys.exit(1)
        update_section(sys.argv[2], sys.argv[3], sys.argv[4])
    
    elif action == "error":
        if len(sys.argv) < 5:
            print("Usage: progress_tracker.py error <course> <section> <error_message>")
            sys.exit(1)
        log_error(sys.argv[2], sys.argv[3], " ".join(sys.argv[4:]))
    
    elif action == "report":
        if len(sys.argv) < 3:
            print("Usage: progress_tracker.py report <course_name>")
            sys.exit(1)
        report(" ".join(sys.argv[2:]))
    
    elif action == "list":
        list_courses()
    
    elif action == "summary":
        if len(sys.argv) < 3:
            print("Usage: progress_tracker.py summary <course_name>")
            sys.exit(1)
        report(" ".join(sys.argv[2:]))
        print("\n🎉 Course automation complete!")
    
    else:
        print(f"Unknown action: {action}")
        print(__doc__)
        sys.exit(1)
