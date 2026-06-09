#!/usr/bin/env python3
"""
Quiz Content Extractor
Extracts quiz questions and options from a Coursera quiz page snapshot.
Designed to be used by AI agents to analyze quiz content before answering.

Usage:
  python quiz_content_extractor.py <page_text_file>
  python quiz_content_extractor.py --stdin < page_text
  echo "quiz text" | python quiz_content_extractor.py --stdin

The agent should take a browser snapshot of the quiz page and save it to a text file,
then run this script to extract structured question data.
"""

import sys
import re
import json

def extract_questions(text):
    """Extract questions and options from quiz page text."""
    questions = []
    current_question = None
    
    lines = text.split("\n")
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        i += 1
        if not line:
            continue
        
        # Detect question patterns
        # Pattern 1: "Question 1" or "Q1" or "1."
        if re.match(r"^(Question|Q)\s*\d+", line, re.IGNORECASE):
            if current_question:
                questions.append(current_question)
            # Look ahead: if next non-empty line is the actual question text, use it
            actual_q = line
            j = i
            while j < len(lines):
                next_line = lines[j].strip()
                j += 1
                if not next_line:
                    continue
                # Check if next line looks like a question (ends with ? or starts with question phrase)
                question_starters = ["which of", "what is", "what are", "how does", "why does",
                                   "when should", "where does", "select all", "choose the"]
                is_question_text = (next_line.endswith("?") and len(next_line) > 15) or \
                                   any(next_line.lower().startswith(s) for s in question_starters)
                if is_question_text:
                    actual_q = next_line
                    i = j  # consume the line
                break
            current_question = {"question": actual_q, "options": [], "type": "unknown"}
            continue
        
        # Pattern 2: Lines ending with "?" are likely questions
        if line.endswith("?") and len(line) > 15:
            if current_question and not current_question["options"] and current_question["type"] == "unknown":
                # Has a header but no question text yet — this IS the question text
                current_question["question"] = line
            else:
                if current_question:
                    questions.append(current_question)
                current_question = {"question": line, "options": [], "type": "unknown"}
            continue
        
        # Pattern 3: Lines that start with question-like phrases
        question_starters = ["which of", "what is", "what are", "how does", "why does", 
                           "when should", "where does", "select all", "choose the"]
        if any(line.lower().startswith(s) for s in question_starters):
            if current_question and not current_question["options"] and current_question["type"] == "unknown":
                # Has a header but no question text yet — this IS the question text
                current_question["question"] = line
            else:
                if current_question:
                    questions.append(current_question)
                current_question = {"question": line, "options": [], "type": "unknown"}
            continue
        
        # Detect option patterns
        # Pattern: A), B), C), D) or a), b), c), d)
        option_match = re.match(r"^([A-Za-z])[).]\s*(.*)", line)
        if option_match and current_question:
            current_question["options"].append({
                "letter": option_match.group(1).upper(),
                "text": option_match.group(2).strip()
            })
            continue
        
        # Pattern: Numbered options 1), 2), 3) or 1., 2., 3.
        num_match = re.match(r"^(\d+)[).]\s*(.*)", line)
        if num_match and current_question:
            current_question["options"].append({
                "letter": num_match.group(1),
                "text": num_match.group(2).strip()
            })
            continue
        
        # Pattern: Checkbox options (for multi-select)
        checkbox_match = re.match(r"^[☐☑✓✗■□]\s*(.*)", line)
        if checkbox_match and current_question:
            current_question["type"] = "multi-select"
            current_question["options"].append({
                "text": checkbox_match.group(1).strip()
            })
            continue
        
        # Pattern: Options that start with "- " or "* "
        bullet_match = re.match(r"^[-*]\s+(.*)", line)
        if bullet_match and current_question and len(current_question["options"]) > 0:
            current_question["options"].append({
                "text": bullet_match.group(1).strip()
            })
            continue
        
        # Append to current question if it's part of the question text
        if current_question and not current_question["options"] and len(line) > 5:
            current_question["question"] += " " + line
    
    # Don't forget the last question
    if current_question:
        questions.append(current_question)
    
    # Detect question types
    for q in questions:
        if len(q["options"]) == 0:
            q["type"] = "free-text"
        elif q["type"] == "unknown":
            # Check for "select all that apply" in the question
            if any(phrase in q["question"].lower() for phrase in 
                   ["select all", "choose all", "check all", "all that apply"]):
                q["type"] = "multi-select"
            else:
                q["type"] = "single-choice"
    
    return questions

def format_for_agent(questions):
    """Format extracted questions for AI agent consumption."""
    if not questions:
        return "No questions detected. The page may not contain quiz content."
    
    output = []
    output.append(f"=== QUIZ CONTENT: {len(questions)} question(s) detected ===\n")
    
    for i, q in enumerate(questions, 1):
        output.append(f"--- Question {i} ({q['type']}) ---")
        output.append(f"Q: {q['question']}")
        
        if q["options"]:
            for opt in q["options"]:
                if "letter" in opt:
                    output.append(f"  {opt['letter']}) {opt['text']}")
                else:
                    output.append(f"  - {opt['text']}")
        else:
            output.append("  [Free text answer required]")
        output.append("")
    
    return "\n".join(output)

def format_as_json(questions):
    """Output as JSON for programmatic use."""
    return json.dumps(questions, indent=2)

if __name__ == "__main__":
    if "--stdin" in sys.argv:
        text = sys.stdin.read()
    elif len(sys.argv) >= 2:
        if sys.argv[1] == "--json":
            text = sys.stdin.read() if len(sys.argv) == 2 else open(sys.argv[2]).read()
            questions = extract_questions(text)
            print(format_as_json(questions))
            sys.exit(0)
        with open(sys.argv[1]) as f:
            text = f.read()
    else:
        print(__doc__)
        sys.exit(1)
    
    questions = extract_questions(text)
    print(format_for_agent(questions))
    print(f"\n--- Extracted {len(questions)} question(s) ---")
    
    if "--json" in sys.argv:
        print("\nJSON output:")
        print(format_as_json(questions))
