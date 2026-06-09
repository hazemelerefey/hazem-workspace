---
name: coursera-automation
description: >
  Automate Coursera course completion end-to-end. Handles login verification,
  course discovery, video/audio watching (with adaptive speed), quiz answering,
  section navigation, and progress tracking. Use when the user wants to:
  (1) Complete Coursera courses automatically, (2) Finish a specialization or
  professional certificate program, (3) Automate video watching and quiz
  completion on Coursera, (4) Speed through enrolled courses, or any task
  involving Coursera course progression.
---

# Coursera Automation

Automate Coursera course completion end-to-end: login verification, course discovery, video/audio watching, quiz answering, section navigation, and progress tracking.

## Prerequisites

- **Browser automation** — you must have a controllable browser (Playwright, Puppeteer, Selenium, or OpenClaw browser tool)
- **Python 3.8+** — for helper scripts (progress tracking, quiz extraction)
- **Coursera account** — user must be enrolled in courses; you do NOT handle credentials

## Quick Start

Trigger phrases that activate this skill:

| Phrase | Meaning |
|--------|---------|
| "Open Coursera" | Start a Coursera automation session |
| "Finish my courses" | Complete all enrolled courses |
| "Complete my program" | Finish an entire specialization/certificate |
| "Automate Coursera" | Begin end-to-end Coursera automation |

---

## Phase 1: Setup & Discovery

### 1. Launch Browser

Open a browser tab/window you can control programmatically.

### 2. Navigate to Coursera

```
Navigate to: https://www.coursera.org
```

### 3. Check Login Status

- **Logged in:** Look for user avatar or profile icon in the top-right corner. If present → proceed.
- **Not logged in:** The page shows a "Log In" or "Join for Free" button. Inform the user:

> "Please log in to Coursera in the browser, then tell me when ready."

- **Do NOT enter credentials.** Wait for user confirmation before proceeding.

### 4. Discover Courses

Navigate to the learner dashboard:

```
Navigate to: https://www.coursera.org/learner
```

**Identify programs vs. individual courses:**

- **Programs/Specializations:** Grouped under a program heading (e.g., "Google Data Analytics Professional Certificate"). Each program contains multiple courses.
- **Individual courses:** Standalone enrollments not part of a program.

**For each program:**

1. Count total courses in the program
2. Count completed courses (marked with checkmark or "Completed" badge)
3. Count incomplete courses (marked "In Progress" or "Not Started")

**For each course:**

1. Navigate into the course
2. Open the side menu / syllabus
3. Count total modules
4. Count completed modules (checkmark icon)
5. Identify the first incomplete module

### 5. Report Findings

Send a summary to the user:

```
📚 Discovery Complete!

Programs: X
Courses: Y total, Z completed, W remaining

Courses to complete:
  1. [Course Name] — [Progress %]
  2. [Course Name] — [Progress %]
  ...

Ready to start? Say "go" or specify a course.
```

---

## Phase 2: Course Automation

For each course to complete:

### 1. Navigate to the Course

Open the first incomplete course from the discovery results.

### 2. Assess Course Structure

- Open the side menu (syllabus/outline)
- Count total modules and their sections
- Identify which modules/sections are already complete (checkmark icon)
- Identify the first incomplete section

### 3. Work Through Sections Systematically

For each incomplete section:

1. **Use the side menu to jump directly** to the incomplete section — click its name in the sidebar
2. **DO NOT click "Next" blindly** — always verify you're at the correct section
3. **Determine the section type** by inspecting the page content:

| Type | How to Identify |
|------|----------------|
| **Video** | Embedded video player, play button, progress bar |
| **Audio** | Audio player (similar to video but no visual track) |
| **Reading** | Long-form text content, article layout |
| **Quiz** | "Start Quiz", "Submit", question prompts |
| **Peer Review** | "Review your peers", submission upload prompts |
| **Lab/Assignment** | External tool embeds (Jupyter, Rhyme, etc.) |

4. **Handle each type** per the relevant phase below
5. **Verify completion** — after handling, check that the section now shows a checkmark in the sidebar
6. **Report module completion** when all sections in a module are done
7. **Report course completion** when all modules are done

---

## Phase 3: Video/Audio Completion

### ⚠️ CRITICAL RULES — VIOLATIONS WILL BREAK AUTOMATION

- **NEVER skip ahead or seek to end** — Coursera tracks actual watch time
- **NEVER use speed above 2x** — triggers detection and resets progress
- **ALWAYS wait for video to finish naturally** — monitor progress bar to 100%
- **ALWAYS check current playback speed before adjusting** — read the speed button text
- **ALWAYS click "Mark as complete" after video ends** — some videos require manual completion

### Step-by-Step Video Handling

#### 1. Identify Content Type

- **Video:** Look for a `<video>` element or video player container with play/pause controls
- **Audio:** Look for an `<audio>` element or audio-only player (no video track)

#### 2. Check Playback Speed

Read the text on the playback speed button. It typically displays the current speed (e.g., "1x", "1.25x", "1.5x", "2x").

**Speed button locations** (Coursera patterns):

- Inside the video player controls bar
- May be labeled "Speed" with current value
- Sometimes a gear/settings icon that reveals speed options

#### 3. Set Playback Speed to 2x

If current speed is below 2x:

1. Click the speed button
2. Select "2" or "2x" from the dropdown/menu
3. Verify the button now shows "2x"

If already at 2x, proceed without clicking.

#### 4. Play the Video

Click the play button (▶) if the video is not already playing.

#### 5. Monitor for Completion

- Check every **30–60 seconds** by reading the video progress bar or `currentTime` / `duration`
- Do NOT interact with the video player while it's playing (no pausing, seeking, or clicking)
- If the video has **embedded questions** (mid-video quiz prompts), handle them:
  1. Wait for the question to appear
  2. Read the question and options
  3. Select the best answer
  4. Click "Submit" or "Continue"
  5. Resume monitoring

#### 6. Video Ends — Complete It

When the video reaches the end (progress bar at 100% or video pauses at end):

1. Look for a **"Mark as complete"** button — click it
2. If no "Mark as complete", look for **"Go to next item"** — click it
3. If neither appears, some videos auto-complete — verify via sidebar

#### 7. Verify Completion in Sidebar

Check the side menu: the section should now show a **checkmark (✓)** icon next to its name.

- **Checkmark present** → move to next section
- **No checkmark** → try clicking "Mark as complete" again, or wait and re-check

#### 8. Edge Cases

| Issue | Solution |
|-------|----------|
| Video won't play | Refresh page, retry. If still stuck, skip and log. |
| Video stuck buffering | Wait up to 2 minutes. If still stuck, refresh and retry from last position. |
| Embedded question appears | Answer it (see quiz strategies). Video resumes after. |
| "Mark as complete" disabled | Video may not have registered completion. Seek to last 10 seconds and replay end. |
| Speed option not visible | Look for settings/gear icon, or try keyboard shortcut if available. |

---

## Phase 4: Quiz/Assessment Completion

### 1. Detect Quiz Type

| Type | How to Identify |
|------|----------------|
| **Practice quiz** | "Practice Quiz" label, usually ungraded, retryable |
| **Graded quiz** | "Graded Quiz" or "Assessment", affects course grade |
| **Module challenge** | "Module Challenge", comprehensive module-level quiz |
| **Final exam** | "Final Exam", end-of-course assessment |

### 2. Handle Honor Code Dialog

Coursera shows an honor code checkbox before many quizzes:

1. Look for a dialog/modal with text about academic integrity
2. **Check the checkbox** ("I acknowledge…" or similar)
3. Click **"Start"** or **"Begin Quiz"**
4. If no honor code dialog, click **"Start Quiz"** directly

### 3. Answer Each Question

For each question in the quiz:

1. **Read the question** carefully
2. **Read all answer options**
3. **Select the best answer:**

| Confidence | Strategy |
|------------|----------|
| **High** | Select the correct answer immediately |
| **Medium** | Use elimination — rule out obviously wrong options first, then select |
| **Low** | Make your best guess. Note the question for review if retake is allowed. |

4. **Do NOT submit immediately** — answer all questions first, then review

### 4. Submit the Quiz

1. Scroll through all questions to verify each has an answer selected
2. Click **"Submit"** or **"Submit Quiz"**
3. If there's a confirmation dialog ("Are you sure?"), confirm submission

### 5. Handle Results

- **Passed (score meets threshold):** Continue to next section
- **Failed (score below threshold):**
  - If **retake is allowed** → click "Retake" and try again (apply lessons from wrong answers)
  - If **retake is not allowed** → log the score and continue to next section
- **Score not shown immediately:** Wait for grading (some quizzes grade asynchronously)

### 6. Post-Quiz Honor Code

Some quizzes show a second honor code dialog after submission:

1. Check the checkbox
2. Click **"Submit"** or **"Continue"**

For detailed answering strategies, see `references/quiz-answering.md`.

---

## Phase 5: Navigation

### Core Rule: ALWAYS Use the Side Menu

The side menu (syllabus/outline) is your primary navigation tool. It shows all modules and sections with their completion status.

### How to Navigate

1. **Identify the target section** — find the next incomplete section (no checkmark) in the sidebar
2. **Click the section name** in the sidebar — this jumps directly to that section
3. **Wait for the page to load** — verify you're on the correct section by checking the title

### What NOT to Do

- **DO NOT use the "Next" button** between sections — it may skip to a different section or behave inconsistently
- **DO NOT use browser back/forward** — this breaks Coursera's navigation state and may lose progress
- **DO NOT click "Next" blindly** — always verify the destination section

### Identifying Incomplete Sections

In the side menu:

- ✅ **Checkmark (✓)** = completed
- 🔲 **No checkmark** = incomplete (this is your target)
- ⏳ **In progress icon** = partially completed (resume from here)

---

## Phase 6: Progress Reporting

Send progress updates at these milestones:

### After Initial Discovery

```
📚 Discovery Complete!

Programs: X
Courses: Y total, Z completed, W remaining

Starting with: [Course Name]
```

### After Each Module

```
✅ Module [N] complete! [Course Name — X%]
```

### After Each Course

```
🎉 Course [N] complete! "[Course Name]"
[Program progress: X/Y courses done]
```

### On Errors

```
⚠️ [Issue]: [Description]. Skipped and continued.
```

### On Request

Full progress summary with all courses, modules, and error log.

---

## Phase 7: Error Handling

### 🚨 THE AGENT MUST NEVER STOP WORKING

Your job is to keep progressing no matter what. Errors are temporary; automation is continuous.

### Recovery Strategy

1. **Encounter an error** → attempt automatic recovery
2. **Recovery succeeds** → continue normally
3. **Recovery fails** → skip the problematic item → log it → continue to next item
4. **Alert the user** about skipped items but **do NOT wait for response**
5. **Keep working** through the remaining items

### The Only Hard Stop

**Login required** — if you detect a login page or session expiration, stop and ask the user to re-authenticate. This is the ONLY reason to halt.

### Common Errors and Recovery

| Error | Recovery |
|-------|----------|
| Page won't load | Refresh once. If still failing, skip and log. |
| Element not found | Wait 5 seconds, retry once. If still missing, skip and log. |
| Video won't play | Refresh page. If still stuck, skip and log. |
| Quiz submission fails | Retry once. If still failing, skip and log. |
| Unexpected popup | Dismiss it (close button or click outside). Continue. |
| Rate limiting | Wait 30–60 seconds. Retry. |
| Session expired | Stop and ask user to log in again (hard stop). |

### Logging

Log all errors and skipped items to the progress tracker with:

- Timestamp
- Section name
- Error description
- Action taken (retried/skipped)

For the complete error recovery matrix, see `references/error-recovery.md`.

---

## Reference Files

Read these files when you need detailed guidance:

| File | When to Read |
|------|-------------|
| `references/coursera-dom-patterns.md` | First time automating Coursera, or when DOM selectors break after a site update |
| `references/video-completion.md` | When handling video or audio content — playback speed, monitoring, completion |
| `references/quiz-answering.md` | When answering quiz questions — strategies for different question types |
| `references/error-recovery.md` | When encountering errors — complete recovery matrix and fallback strategies |

---

## Scripts

| Script | Usage |
|--------|-------|
| `scripts/progress_tracker.py` | Track and report course completion progress. Run: `python scripts/progress_tracker.py [action]` |
| `scripts/quiz_content_extractor.py` | Extract quiz questions and options from a page snapshot. Run: `python scripts/quiz_content_extractor.py [snapshot_file]` |

---

## Examples

### Example 1: "Open Coursera and finish my courses"

1. Open Chrome browser tab
2. Navigate to `https://www.coursera.org`
3. Check login — see avatar → logged in ✅
4. Navigate to `https://www.coursera.org/learner`
5. Discover: 2 programs, 9 courses total, 3 completed, 6 remaining
6. Report: "📚 Found 6 courses to complete. Starting with Course 4 of Program 1."
7. Begin working through Course 4, Module 1, Section 1…

### Example 2: "Finish Course 5 for me"

1. Open browser → navigate to Coursera
2. Navigate to Course 5 in the learner dashboard
3. Open side menu — assess: 4 modules, Module 1 complete, Module 2 in progress
4. Jump to Module 2, Section 3 (first incomplete)
5. Determine type: Video → check speed (1x) → set 2x → play → wait → mark complete ✓
6. Next section: Quiz → start → answer 5 questions → submit → passed ✓
7. Continue through all remaining modules
8. Report: "🎉 Course 5 complete!"

### Example 3: "Continue where you left off"

1. Open browser → navigate to Coursera
2. Check progress tracker: last session stopped at Course 3, Module 2, Section 5
3. Navigate directly to Course 3 → Module 2 → Section 5
4. Verify section is incomplete (no checkmark)
5. Resume automation from this point

### Example 4: Video handling during automation

1. Navigate to section: "Introduction to Data Analysis" (video)
2. Video player loads — check speed button: shows "1x"
3. Click speed → select "2x" → verify button shows "2x"
4. Click play (▶) — video starts
5. Wait 60 seconds → check progress: 15%
6. Wait 60 seconds → check progress: 30%
7. … (continue monitoring)
8. Video ends (progress 100%) — "Mark as complete" button appears
9. Click "Mark as complete" → button changes to "Completed" ✓
10. Check sidebar: checkmark appears next to section ✅
11. Move to next section

### Example 5: Quiz handling during automation

1. Navigate to section: "Module 2 Quiz" (graded)
2. Honor code dialog appears → check the checkbox → click "Start"
3. Question 1: "What is the primary purpose of ETL?" — high confidence → select "Extract, Transform, Load"
4. Question 2: "Which SQL clause filters rows?" — high confidence → select "WHERE"
5. Question 3: ambiguous question — eliminate options A and C → select B
6. Questions 4–8: answer each
7. Review: all 8 questions answered
8. Click "Submit" → confirmation dialog → confirm
9. Result: 87% — passed ✅
10. Click "Continue" → next section
11. Sidebar: checkmark appears ✅

---

## DO's and DON'Ts

### ✅ DO

- **Use side menu to navigate** — always click section names in the sidebar
- **Check playback speed before videos** — read the button text first
- **Wait for videos to complete at 2x** — monitor progress, don't skip
- **Click "Mark as complete" after each video** — ensure Coursera registers it
- **Verify completion via sidebar** — check for checkmark after each section
- **Send periodic progress updates** — after modules, courses, and errors
- **Log errors and skipped items** — for user review and retry
- **Handle popups automatically** — dismiss unexpected dialogs and overlays
- **Recover and keep working** — never stop on errors

### ❌ DON'T

- **Skip ahead in videos** — Coursera tracks actual watch time
- **Use speed above 2x** — triggers detection and resets progress
- **Click "Next" blindly** — always verify destination via side menu
- **Enter user credentials** — user must log in themselves
- **Stop and wait for user on errors** — skip and continue, alert asynchronously
- **Assume completion without checking sidebar** — always verify checkmark
- **Submit quiz without reading question** — read each question and all options
- **Ignore errors** — log every error for transparency
- **Refresh unnecessarily** — only refresh on actual errors
- **Interact with video while playing** — don't pause, seek, or click the player
