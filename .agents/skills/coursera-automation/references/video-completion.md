# Video Completion Strategy Reference

Reference guide for completing video and audio content on Coursera. This document is written for an AI agent controlling a browser.

---

## Section 1: Video Completion Workflow (Step-by-Step)

```
VIDEO COMPLETION WORKFLOW:

1. DETECT CONTENT TYPE
   - Look for <video> element → video content
   - Look for <audio> element or audio-only player → audio content
   - If neither found → may be reading/quiz content, skip to appropriate handler

2. CHECK CURRENT PLAYBACK SPEED
   - Locate the speed button (usually near the bottom of the player, shows "1x", "1.5x", "2x", etc.)
   - Read the button text to determine current speed
   - If button not found, assume default speed (1x)

3. SET SPEED TO 2x (if not already)
   - If speed < 2x:
     - Click the speed button repeatedly until "2x" is displayed
     - Speed cycle order: 1x → 1.25x → 1.5x → 1.75x → 2x → 1x (loops)
     - After each click, read the button text to verify the new speed
     - Stop clicking once "2x" is shown
   - If speed already 2x: do nothing, proceed to step 4
   - If 2x is not available (cycles past without showing 2x):
     - Use the highest available speed
     - Log the fallback speed used

4. START PLAYBACK
   - Check if video is already playing (look for pause icon vs play icon)
   - If paused: click the play button
   - If already playing: do nothing
   - Verify playback started (progress bar should begin moving, time should increment)

5. MONITOR PROGRESS
   - Enter the monitoring loop (see Section 3)
   - Check every 30-60 seconds for completion signals
   - Do NOT interact with the video player during playback (no seeking, no clicking)

6. HANDLE COMPLETION
   - When video ends, apply this priority order:
     a. If "Mark as complete" button is visible and enabled → click it
     b. If "Go to next item" button appears → click it
     c. If neither appears, check sidebar for checkmark on current section
     d. If section already has checkmark → completion confirmed, proceed
     e. If no completion signal after 30 seconds → refresh page and re-check

7. VERIFY COMPLETION
   - Check the sidebar navigation for a checkmark (✓) on the current section
   - If checkmark present → confirmed complete
   - If no checkmark → wait 10 seconds and re-check once
   - If still no checkmark → log warning, may need manual intervention
```

---

## Section 2: Speed Management

### Detecting Current Speed

The speed button displays the current playback rate as text. Read the button text to determine speed:

| Button Text | Speed    | Action Needed? |
|-------------|----------|----------------|
| `1x`        | 1.0x     | Yes → cycle to 2x |
| `1.25x`     | 1.25x    | Yes → cycle to 2x |
| `1.5x`      | 1.5x     | Yes → cycle to 2x |
| `1.75x`     | 1.75x    | Yes → cycle to 2x |
| `2x`        | 2.0x     | No → already at target |

### How to Cycle Speed

1. Click the speed button once
2. Read the new button text
3. If not yet at "2x", click again
4. Repeat until "2x" is displayed or the cycle loops back to "1x"
5. If the cycle loops to "1x" without ever showing "2x" → 2x is not available on this course. Use whatever the highest speed shown was.

**Important:** Always read the button text after clicking. Do not assume a fixed number of clicks.

### Rules

- **Always check before adjusting.** If already at 2x, do not click — clicking would cycle back to 1x.
- **Some courses cap speed.** If 2x is not available, fall back to the highest available speed. Log this.
- **Audio-only content uses the same logic.** The speed control applies identically to audio players.
- **Do not use JavaScript injection** to set speed beyond what the UI allows. Stick to UI controls.

---

## Section 3: The "Wait for Completion" Monitoring Loop

### Pseudocode

```
function waitForVideoCompletion(estimatedDurationSeconds):
    startTime = now()
    maxWait = estimatedDurationSeconds * 1.5  // safety margin (50% buffer)
    
    // Prevent excessively long waits (cap at 4 hours for very long videos)
    if maxWait > 14400:
        maxWait = 14400
    
    while (now() - startTime) < maxWait:
        
        // === Check 1: "Mark as complete" button ===
        markCompleteButton = findButton("Mark as complete")
        if markCompleteButton is visible and enabled:
            click(markCompleteButton)
            wait(3 seconds)  // let UI register the click
            log("Marked as complete via button")
            return SUCCESS
        
        // === Check 2: "Go to next item" button ===
        goToNextButton = findButton("Go to next item")
        if goToNextButton is visible:
            click(goToNextButton)
            log("Navigated to next item via button")
            return SUCCESS
        
        // === Check 3: Progress bar at 100% ===
        progressPercent = readProgressBar()
        if progressPercent >= 100:
            wait(5 seconds)  // give UI time to update
            // Re-check for mark complete button after progress hits 100%
            markCompleteButton = findButton("Mark as complete")
            if markCompleteButton is visible and enabled:
                click(markCompleteButton)
                log("Marked as complete after reaching 100%")
                return SUCCESS
            // If no button but progress is 100%, consider it done
            log("Progress at 100%, no mark button found")
            return SUCCESS
        
        // === Check 4: Sidebar checkmark ===
        if currentSectionHasCheckmark():
            log("Completion confirmed via sidebar checkmark")
            return SUCCESS
        
        // === Check 5: Video element ended state ===
        videoElement = findVideoElement()
        if videoElement exists and videoElement.ended == true:
            log("Video element reports ended state")
            wait(3 seconds)
            // Try to mark complete one more time
            markCompleteButton = findButton("Mark as complete")
            if markCompleteButton is visible:
                click(markCompleteButton)
            return SUCCESS
        
        // === Wait before next check ===
        wait(30 seconds)
    
    // === Timeout reached ===
    log("WARNING: Video completion wait timed out after " + maxWait + " seconds")
    return TIMEOUT

function readProgressBar():
    // Try multiple methods to read progress
    // Method 1: Read progress bar width/style attribute
    progressBar = findElement("[role='progressbar']")
    if progressBar exists:
        return progressBar.getAttribute("aria-valuenow") or parseWidthPercent(progressBar)
    
    // Method 2: Read time display (current / total)
    currentTime = readCurrentTime()
    totalTime = readTotalTime()
    if currentTime and totalTime and totalTime > 0:
        return (currentTime / totalTime) * 100
    
    // Method 3: Check for completion class/attribute on player
    player = findVideoPlayer()
    if player has "completed" class:
        return 100
    
    return 0  // unknown progress
```

### Monitoring Interval Rationale

| Interval | Use Case |
|----------|----------|
| Every 30 seconds | Standard check interval — optimal balance of responsiveness and resource usage |
| Every 60 seconds | Acceptable for very long videos (>30 min) to reduce overhead |
| Every 10 seconds | Only in the last 10% of video — use when near completion |
| Every 5 seconds | Only immediately after progress hits 100% — final confirmation window |

---

## Section 4: Edge Cases

| Edge Case | Detection | Recovery Action |
|-----------|-----------|-----------------|
| **Video won't play** | Play button visible but video time doesn't advance after 10 seconds | (1) Click play button again. (2) Check for overlay dialogs (popups, surveys, cookie banners) and dismiss them. (3) Refresh the page. (4) Max 3 retries. If all fail, log error and skip. |
| **Video stuck at certain percentage** | Progress bar unchanged for >2 minutes during playback | (1) Wait 2 minutes — may be buffering. (2) If still stuck, refresh the page. (3) Video should resume from last checkpoint. (4) Re-enter monitoring loop. |
| **Speed button not found** | Button selector returns no match | Proceed at whatever speed is currently active. Log a warning: "Speed button not found, using default speed." Do not fail the task. |
| **"Mark complete" button never appears** | After video ends, no mark button after 30 seconds | (1) Check sidebar — if current section has a checkmark, it auto-completed. (2) Check for alternative completion UI ("Continue", "Next", checkmark icon). (3) Some sections auto-complete when video ends — no action needed. (4) If truly stuck, refresh and re-check. |
| **Audio-only content** | No <video> element; audio element or audio-only player present | Apply identical workflow but target the audio element controls. Speed management works the same. Monitoring works the same. No visual progress to screenshot. |
| **Interactive video with embedded questions** | Video pauses unexpectedly mid-playback; question overlay appears | (1) Detect the question overlay (look for form elements, radio buttons, submit button within the player). (2) Read the question. (3) Select an answer (if answer is known; if not, select first option and note uncertainty). (4) Click "Submit" or "Check Answer". (5) After answer is processed, click "Continue" to resume playback. (6) Re-enter monitoring loop. |
| **Video has multiple parts/chapters** | Video player shows "Part 1 of N" or chapter indicators | (1) Complete each part sequentially. (2) After each part ends, look for "Next part" or chapter navigation. (3) Do not skip ahead. (4) Monitor each part individually. (5) Final completion check after last part. |
| **Live session content** | Content labeled "Live" or "Join live session" or has a countdown timer | **Skip entirely.** Cannot automate live content. Log: "Skipped live session content — requires manual attendance." Move to next section. |
| **Video requires authentication refresh** | Video stops playing; page redirects to login or shows auth prompt | **Do not attempt to re-authenticate.** Alert the user immediately: "Video playback stopped — authentication may have expired. Please re-login manually." Stop automation until user intervenes. |
| **Transcript/subtitles blocking controls** | Subtitle overlay covers play/speed controls | (1) Try clicking through the overlay. (2) If blocked, try disabling subtitles via the CC button. (3) As a last resort, use keyboard shortcuts (space for play/pause). |
| **Network interruption** | Video shows buffering spinner for >1 minute | (1) Wait up to 2 minutes. (2) If still buffering, refresh the page. (3) Video should resume from checkpoint. (4) If repeated (3+ times in one video), log error and alert user about network issues. |
| **Embedded external video** | Video plays in an iframe from YouTube, Kaltura, or other provider | (1) Switch context to the iframe. (2) Apply same workflow to iframe player controls. (3) Speed management depends on the embedded player's UI — adapt selectors. (4) Completion tracking still uses Coursera's outer frame. |

---

## Section 5: Timing and Realism

### Realistic Timing Expectations

| Video Length | At 1x Speed | At 2x Speed | With Buffer (+15%) |
|-------------|-------------|-------------|---------------------|
| 5 minutes   | 5 min       | 2.5 min     | ~2.9 min            |
| 10 minutes  | 10 min      | 5 min       | ~5.75 min           |
| 20 minutes  | 20 min      | 10 min      | ~11.5 min           |
| 30 minutes  | 30 min      | 15 min      | ~17.25 min          |
| 60 minutes  | 60 min      | 30 min      | ~34.5 min           |

### Buffer Explanation

- **10-15% buffer** is added to account for:
  - UI load time (player initialization, ad pre-rolls)
  - Speed button cycling and verification
  - Monitoring loop overhead (30-second check intervals)
  - Completion button detection and clicking
  - Page transitions between sections

### Key Rules

1. **Do not check too frequently.** Checking every 30 seconds is optimal. Checking every 5 seconds wastes resources and may trigger anti-bot detection. Checking every 5 minutes risks missing completion signals.

2. **Do not try to be faster than 2x.** Coursera's maximum is 2x. Attempting to inject faster playback via JavaScript will either fail silently or break the player. Stick to UI controls only.

3. **Some courses enforce minimum watch time.** A small number of Coursera courses track actual watch time regardless of playback speed. If a video doesn't mark complete despite reaching 100%, this may be the cause. Recovery: wait the full real-time duration at 1x equivalent, then re-check.

4. **Do not seek/fast-forward.** Skipping ahead in the video will likely not count toward completion. Coursera tracks cumulative watch time. Let the video play naturally from start to finish.

5. **Account for ads.** Some videos have pre-roll ads. Wait for ads to finish before starting the monitoring loop. Ad detection: look for "Skip ad" button or ad overlay indicators.

6. **Timestamp your logs.** Always log when a video started monitoring and when it completed. This helps debug timing issues and estimate remaining time for the full course.

### Estimating Remaining Time

```
function estimateRemainingTime(sections):
    totalSeconds = 0
    for each section in sections:
        if section is video and not section.completed:
            totalSeconds += section.duration
    
    // Apply 2x speed + 15% buffer
    estimatedRealSeconds = (totalSeconds / 2) * 1.15
    
    return estimatedRealSeconds
```
