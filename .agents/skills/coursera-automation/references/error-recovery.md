# Error Recovery Reference

Comprehensive error scenarios and recovery procedures for Coursera automation.

---

## 1. Error Recovery Matrix

| Error | Recovery Action | Alert User? | Max Retries |
|-------|----------------|-------------|-------------|
| Login required | Notify user, wait for credentials | YES, then pause | 1 |
| Video won't play | Refresh page, click play again | Only if all retries fail | 3 |
| Video stuck mid-play | Wait 2min, refresh, resume | Only if persists | 2 |
| Quiz submission failed | Retry submit, refresh if needed | Only if all retries fail | 3 |
| Honor code dialog | Auto-dismiss (check box + continue) | NO | 1 |
| Popup/overlay blocking | Auto-dismiss (close/X button) | NO | 3 |
| Page not loading | Wait 30s, refresh, retry | Only if all retries fail | 3 |
| Section won't mark complete | Refresh, try clicking again | Only if persists | 3 |
| Peer review required | Skip, note for user | YES | 0 |
| Group assignment required | Skip, note for user | YES | 0 |
| Course certificate required | Note completion, inform user | YES | 0 |
| Rate limited / too many requests | Wait 60s, slow down | NO | 3 |
| Navigation lost (wrong page) | Navigate back to course, use menu | NO | 2 |
| Element not found | Wait 5s, retry, refresh if needed | Only if all retries fail | 3 |
| Browser tab closed | Open new tab, navigate back | NO | 1 |
| Network error | Wait 30s, refresh | Only if persists | 3 |
| Quiz time expired | Log it, move to next section | YES | 0 |
| Video requires Flash/unsupported | Skip, note for user | YES | 0 |

---

## 2. Autonomous Operation Principle

```
AUTONOMOUS OPERATION PRINCIPLE:
- The agent MUST handle issues independently
- NEVER stop working and wait for user input
- If something fails → try recovery → if recovery fails → alert user AND continue to next task
- Keep a log of unresolved issues for user review
- If the user is not available, the agent keeps working on other sections/courses
- The ONLY hard stop: login required (cannot proceed without credentials)
- Even if 3 sections fail in a row, keep going with the 4th
- Report failures but don't let them block progress
```

### Decision Flow

```
Error occurs
  → Is it "Login required"?
      YES → Alert user, pause, wait for credentials (HARD STOP)
      NO  → Attempt recovery
          → Recovery succeeded? → Continue
          → Recovery failed? → Alert user, skip item, continue to next task
```

---

## 3. Retry Patterns

### Exponential Backoff

Use exponential backoff between retries to avoid hammering the page or triggering rate limits:

| Retry # | Delay | Cumulative Wait |
|---------|-------|-----------------|
| 1st retry | 5 seconds | 5s |
| 2nd retry | 15 seconds | 20s |
| 3rd retry | 45 seconds | 65s |

### General Rules

- **Max retries per action:** 3 (unless specified otherwise in the matrix)
- **After max retries:** Skip the item, log it, move on
- **After skipping 3 items in same module:** Alert user about the pattern, but keep going
- **Refresh page as last resort** before skipping
- **Never retry the same error infinitely** — respect the retry limit

### Pseudocode

```python
def retry_with_backoff(action, max_retries=3):
    delays = [5, 15, 45]  # seconds
    for attempt in range(max_retries):
        try:
            result = action()
            if result.success:
                return result
        except Error as e:
            log_error(e, attempt)
        
        if attempt < max_retries - 1:
            wait(delays[attempt])
    
    # All retries exhausted
    skip_item()
    log_failure(action, max_retries)
    return None  # Continue to next task
```

---

## 4. Recovery Procedures (Detailed)

### 4.1 Login Required

**Severity:** HARD STOP — cannot proceed without credentials.

**Steps:**
1. **Detect:** Page redirected to login URL, or "Please sign in" / "Log in" message visible on page
2. **Alert user:**
   ```
   ⚠️ Login Required: Coursera session expired.
      Action: Waiting for you to log in.
      Please log in to Coursera and tell me when ready.
   ```
3. **Wait** for user confirmation ("ready", "done", "logged in", etc.)
4. **Verify:** Confirm the page is now on the course dashboard or a course page
5. **Resume** from the last completed section

**Notes:**
- This is the ONLY scenario where the agent pauses and waits for user input
- Do not attempt to enter credentials — wait for the user to do it
- After user confirms, verify login succeeded before continuing

---

### 4.2 Video Won't Play

**Steps:**
1. Wait 5 seconds (allow page to fully load)
2. Check for overlay dialogs or cookie banners → dismiss if found
3. Click the play button
4. Wait 10 seconds, check if video is playing (progress bar moving, time advancing)
5. If still not playing:
   - Refresh the page (`Ctrl+R` or navigate to URL)
   - Wait for page to load
   - Navigate back to the video section if needed
   - Click play again
6. If still not playing after 3 refresh attempts:
   - Skip this video section
   - Log the failure
   - Move to the next section

**Detection signals:**
- Video element exists but `currentTime` stays at 0
- Play button still visible (not in "playing" state)
- Error message overlay on video player

---

### 4.3 Video Stuck Mid-Play

**Steps:**
1. Wait 2 minutes (some videos buffer slowly, especially on slow connections)
2. Check if the progress bar is advancing (compare `currentTime` at two points)
3. If progress bar is NOT moving after 2 minutes:
   - Refresh the page
   - Video should resume from last watched position (Coursera tracks this server-side)
   - Wait 30 seconds, verify progress is resuming
4. If stuck again after refresh:
   - Skip this video section
   - Log the failure
   - Move to the next section

**Detection signals:**
- `currentTime` value hasn't changed in 2+ minutes
- Loading spinner visible on video player
- Network activity indicator stuck

---

### 4.4 Quiz Submission Failed

**Steps:**
1. Click the "Submit" button again
2. Wait 10 seconds for response
3. If submission still fails:
   - Refresh the page
   - Navigate back to the quiz
   - Verify answers are preserved (Coursera usually saves answers automatically)
   - Click "Submit" again
4. If submission fails a third time:
   - Skip this quiz
   - Log the failure with details of the quiz
   - Move to the next section

**Notes:**
- Coursera auto-saves quiz answers, so refreshing should not lose them
- Check for validation errors (unanswered questions) before submitting
- Some quizzes have time limits — watch for time-expired errors

---

### 4.5 Honor Code Dialog

**Steps:**
1. Look for the honor code / academic integrity dialog
2. Check the "I agree" or "Honor code" checkbox
3. Click "Continue" or "Submit" button
4. Verify the dialog has been dismissed

**Notes:**
- This is fully automatable — no user input needed
- If the dialog structure changes, look for any checkbox + button combination
- Honor code dialogs appear once per course, not per section

---

### 4.6 Popup/Overlay Blocking

**Steps:**
1. Look for close buttons: X icon, "Close", "Dismiss", "OK", "Got it"
2. Click the close button
3. If no close button found → press `Escape` key
4. If still present → click outside the dialog area (on the backdrop/overlay)
5. If still present → refresh the page
6. If still present after refresh → try clicking specific dismiss elements

**Common popups on Coursera:**
- Cookie consent banners
- "Upgrade to premium" prompts
- Notification permission dialogs
- "Continue learning" modals
- Browser notification prompts
- Rating/feedback prompts

---

### 4.7 Page Not Loading

**Steps:**
1. Wait 30 seconds (slow connections or heavy pages)
2. Check if the page shows any content at all (even partial)
3. If blank or error page:
   - Refresh (`F5` or `Ctrl+R`)
   - Wait 30 seconds
4. If still not loading:
   - Check if the URL is correct
   - Try navigating directly to the course page
5. If still failing after 3 attempts:
   - Skip this section
   - Log the failure
   - Try the next section (might be a page-specific issue)

---

### 4.8 Section Won't Mark Complete

**Steps:**
1. Verify you've actually completed the section content (watched video, answered quiz, etc.)
2. Look for the "Mark as Complete" or checkmark button
3. Click it
4. Wait 5 seconds
5. Check if the section now shows as completed (checkmark icon, progress indicator)
6. If not marked:
   - Refresh the page
   - Try clicking the completion button again
7. If still not marking after 3 attempts:
   - Log the issue
   - Move to the next section (Coursera may auto-mark it later)

---

### 4.9 Peer Review Required

**Steps:**
1. Detect: Page shows "Peer Review" or "Review your peers' work" prompt
2. Log the requirement:
   ```
   ⚠️ Peer Review Required: "Assignment Name"
      Section: Module N - Section Name
      Action: Skipped (cannot auto-complete peer reviews)
      Impact: This section requires manual peer review to complete
   ```
3. Skip this section
4. Move to the next section

**Notes:**
- Peer reviews cannot be automated — they require reading and grading others' work
- Mark this as a manual task for the user
- Some courses allow skipping peer reviews for completion; check course requirements

---

### 4.10 Group Assignment Required

**Steps:**
1. Detect: Page shows "Group Assignment" or "Team Project" prompt
2. Log the requirement:
   ```
   ⚠️ Group Assignment Required: "Assignment Name"
      Section: Module N - Section Name
      Action: Skipped (cannot auto-complete group assignments)
      Impact: This section requires group participation
   ```
3. Skip this section
4. Move to the next section

---

### 4.11 Course Certificate Required

**Steps:**
1. Detect: Course is fully completed, but certificate/payment prompt appears
2. Log the completion:
   ```
   ✅ Course Completed: "Course Name"
      All sections finished.
      Certificate: Requires payment/manual action to claim.
   ```
3. Inform the user that the course content is complete
4. Note that certificate claiming requires user action

---

### 4.12 Rate Limited / Too Many Requests

**Steps:**
1. Detect: HTTP 429 status, "Too many requests" message, or sudden widespread failures
2. Wait 60 seconds
3. Slow down all subsequent actions:
   - Add 5-second delay between page navigations
   - Add 2-second delay between clicks
   - Add 10-second delay between section transitions
4. If still rate limited after 60 seconds:
   - Wait 5 minutes
   - Resume at slower pace
5. If still rate limited after 5 minutes:
   - Alert user about the rate limiting
   - Continue at the slowest pace possible

**Prevention:**
- Default pacing: 2-3 seconds between actions
- Add random jitter (±1 second) to appear more human-like
- Avoid rapid page refreshes

---

### 4.13 Navigation Lost (Wrong Page)

**Steps:**
1. Detect: Current URL doesn't match expected course/section URL
2. Check if the course sidebar/menu is visible
3. If menu visible:
   - Click the correct section in the course navigation
4. If menu not visible:
   - Navigate to the course main page URL
   - Use the course menu to find the correct section
5. If still lost after 2 attempts:
   - Navigate to the course dashboard
   - Find the last incomplete section
   - Resume from there

---

### 4.14 Element Not Found

**Steps:**
1. Wait 5 seconds (page may still be loading or rendering)
2. Take a new snapshot of the page
3. Search for the element using alternative selectors:
   - Try by text content
   - Try by ARIA role/label
   - Try by CSS class
   - Try by nearby elements
4. If still not found → refresh the page
5. Take another snapshot and search again
6. If still not found after refresh:
   - Skip this action
   - Log what element was missing
   - Move to the next task

---

### 4.15 Browser Tab Closed

**Steps:**
1. Detect: Tab reference is no longer valid, or all tabs are gone
2. Open a new tab
3. Navigate to the course page URL (from the known course URL or history)
4. Verify the page loaded correctly
5. Resume from the last known section

**Prevention:**
- Periodically verify the tab is still open
- Keep the course URL bookmarked or noted

---

### 4.16 Network Error

**Steps:**
1. Detect: "Network error", "Connection refused", "ERR_NETWORK", blank page
2. Wait 30 seconds (network may be temporarily down)
3. Refresh the page
4. If still failing:
   - Wait another 30 seconds
   - Refresh again
5. If still failing after 3 attempts:
   - Log the network error
   - Skip the current section
   - Try the next section (may be a page-specific issue)
6. If ALL sections fail with network errors:
   - Alert user: possible network outage
   - Stop attempting until network recovers

---

### 4.17 Quiz Time Expired

**Steps:**
1. Detect: "Time expired" or "Quiz closed" message on quiz page
2. Log the expired quiz:
   ```
   ⚠️ Quiz Time Expired: "Quiz Name"
      Section: Module N - Section Name
      Action: Moving to next section
      Impact: This quiz may need to be retaken
   ```
3. Move to the next section
4. Note: Some quizzes allow retakes; the user may want to retry manually

---

### 4.18 Video Requires Flash / Unsupported Format

**Steps:**
1. Detect: "Flash required", "Plugin required", or video player shows unsupported format error
2. Log the issue:
   ```
   ⚠️ Unsupported Video: "Video Title"
      Section: Module N - Section Name
      Action: Skipped (unsupported video format)
      Impact: This video may need to be watched on a different browser or device
   ```
3. Skip this video
4. Move to the next section

---

## 5. Error Logging Format

All errors must be logged in a consistent format for user review.

### Log Entry Template

```
ERROR LOG FORMAT:
Timestamp: [ISO datetime, e.g., 2026-06-06T14:30:00+03:00]
Section: [Module N - Section Name]
Error: [Description of what went wrong]
Recovery: [What recovery steps were attempted]
Outcome: [Recovered / Skipped / Failed]
Notes: [Any additional context]
```

### Example Log Entries

```
Timestamp: 2026-06-06T14:30:00+03:00
Section: Module 3 - Data Visualization Basics
Error: Video player would not start playback after page load
Recovery: Dismissed cookie overlay, clicked play 3 times, refreshed page 3 times
Outcome: Skipped
Notes: Video element present but play button unresponsive; may be browser compatibility issue

Timestamp: 2026-06-06T14:45:00+03:00
Section: Module 4 - Quiz: Neural Networks
Error: Quiz submit button returned network error
Recovery: Retried submit, refreshed page, verified answers preserved, retried submit
Outcome: Recovered (succeeded on 2nd attempt after refresh)

Timestamp: 2026-06-06T15:00:00+03:00
Section: Module 5 - Peer Review Assignment
Error: Peer review required — cannot be automated
Recovery: N/A (no automated recovery possible)
Outcome: Skipped
Notes: User must complete peer review manually to finish this section
```

### Log Storage

- Store error logs in the session or in a temporary file
- Present accumulated errors to the user at the end of the run or when requested
- Group errors by module for easy review

---

## 6. User Alert Format

Alerts are sent to the user only when the matrix says "YES" or "Only if all retries fail."

### Alert Template

```
ALERT FORMAT:
⚠️ [Issue Type]: [Brief description]
   Section: [Module N - Section Name]
   Action: [What happened / what was skipped]
   Impact: [Does this affect course completion?]
```

### Example Alerts

```
⚠️ Video Failed: "Data Visualization Basics" wouldn't load after 3 retries
   Section: Module 3 - Lesson 2
   Action: Skipped this video
   Impact: Course still completable, but this section may need manual completion
```

```
⚠️ Login Required: Coursera session expired
   Section: Module 4 - Quiz
   Action: Paused automation, waiting for login
   Impact: Cannot proceed without authentication
```

```
⚠️ Peer Review Required: "Final Project Review"
   Section: Module 8 - Final Assignment
   Action: Skipped (automated completion not possible)
   Impact: This section requires manual peer review to earn credit
```

```
⚠️ Pattern Detected: 3 consecutive sections skipped in Module 5
   Section: Module 5 (multiple sections)
   Action: Continuing to Module 6
   Impact: Module 5 may have systemic issues; recommend manual review
```

### Alert Rules

- **Login required:** Always alert immediately, pause automation
- **Peer review / Group assignment:** Always alert, skip, continue
- **Repeated failures (3+ in a module):** Alert about the pattern
- **Everything else:** Only alert if all retries are exhausted
- **Never block progress on alerts** — send the alert and keep working
