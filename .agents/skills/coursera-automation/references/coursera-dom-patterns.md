# Coursera DOM Patterns Reference

> **Purpose:** Comprehensive reference of Coursera's page structures, selectors, and UI patterns for AI-driven automation. Written for an agent that has never seen Coursera before.
>
> **Last reviewed:** 2026-06-06
>
> ⚠️ CSS selectors and class names may change with Coursera updates. Always prefer semantic/ARIA attributes and visible text over brittle class-name selectors. Use the "How to identify" guidance in each section as the primary strategy, with selectors as fallback.

---

## Table of Contents

1. [Course Dashboard Page](#1-course-dashboard-page)
2. [Course Content Page](#2-course-content-page)
3. [Video Player DOM Patterns](#3-video-player-dom-patterns)
4. [Quiz and Assessment DOM Patterns](#4-quiz-and-assessment-dom-patterns)
5. [Navigation Patterns](#5-navigation-patterns)
6. [Login and Session Patterns](#6-login-and-session-patterns)
7. [Common Popups and Dialogs](#7-common-popups-and-dialogs)

---

## 1. Course Dashboard Page

**URL pattern:** `https://www.coursera.org/learner/` or `https://www.coursera.org/?authMode=login`

The dashboard is the landing page after login. It shows all enrolled courses and programs.

### 1.1 Enrolled Courses

**How to identify:** The dashboard lists enrolled courses as cards in a grid or list layout. Each card typically contains:
- Course thumbnail image
- Course title (a link)
- Partner/university name
- Progress percentage or progress bar
- A "Continue" or "Resume" button/link

**Common selectors:**
```
[data-testid="enrollment-card"]
.cds-Card
[data-e2e="course-card"]
a[href*="/learn/"]
```

**How to find course progress:** Look for:
- A progress bar element (often a `<div>` with a width style like `width: 45%`)
- Text showing "45% complete" or similar percentage
- A `<span>` or `<div>` containing a percentage number near the course card

**How to find the "Continue" button:** Look for:
- A button or link with text "Continue", "Resume", or "Start Learning"
- Often styled as a primary button near the bottom of each course card
- Selector: `a[href*="/learn/"]` combined with text content matching "Continue"

### 1.2 Programs vs. Individual Courses

**How to distinguish:** Programs/specializations appear differently from individual courses:
- **Programs** often show "Specialization" or "Professional Certificate" badge/tag
- Programs may show a collection of sub-courses with individual progress
- The card may show "X courses" count
- URL pattern for program pages: `https://www.coursera.org/professional-certificates/...` or `https://www.coursera.org/specializations/...`

**How to see all courses in a program:**
- Click the program card to open the program page
- The program page lists all individual courses with their completion status
- Look for a course list/table with checkmarks for completed courses
- Each course row has a "Go to Course" or "Continue" button

### 1.3 Dashboard Navigation Tabs

The dashboard may have tabs to filter views:
- "My Courses" — enrolled courses
- "My Learning" — alternative label for the same
- "In Progress" — courses currently being taken
- "Completed" — finished courses

---

## 2. Course Content Page

**URL pattern:** `https://www.coursera.org/learn/<course-slug>/...`

When you enter a course, you see the content area with a sidebar navigation.

### 2.1 Sidebar Navigation Structure

**How to identify:** The sidebar (left panel) lists the course's module/week structure as a collapsible tree:

```
├── Module 1: Introduction
│   ├── 1.1 Video: Welcome          ✓
│   ├── 1.2 Reading: Overview        ✓
│   ├── 1.3 Quiz: Module 1 Quiz      ○
│   └── 1.4 Discussion Prompt        ○
├── Module 2: Core Concepts
│   ├── 2.1 Video: Key Ideas         ○
│   └── ...
```

**Common selectors:**
```
[data-testid="sidebar-navigation"]
.cds-Sidebar
[role="navigation"]
[aria-label*="course" i]
```

**Module headers** are typically collapsible `<button>` or `<div>` elements with:
- Module/week title
- Progress indicator (e.g., "2/5 completed")
- Expand/collapse arrow icon

**Section items** within each module are links (`<a>` elements) that navigate to specific content items. Each section item shows:
- Section title
- Content type icon (video, reading, quiz, lab)
- Completion status (checkmark or empty circle)

### 2.2 Completion Indicators

| State | Visual | How to Identify |
|-------|--------|-----------------|
| **Completed** | ✓ checkmark (green or colored) | SVG checkmark icon, `aria-label` contains "completed", class may contain "completed" or "done" |
| **In Progress** | Partially filled circle/bar | Progress bar with partial fill, or half-colored icon |
| **Not Started** | Empty/gray circle or icon | No checkmark, gray/muted icon color |
| **Current** | Highlighted background | Active/selected state, distinct background color |

**Common selectors for completion:**
```
[data-testid="completion-checkmark"]
svg[data-icon="check"]
.cds-Completed
[aria-label*="completed" i]
```

### 2.3 Identifying Current Section

The currently active/selected section in the sidebar is highlighted:
- Different background color (often a subtle blue or gray highlight)
- May have a left border accent
- The corresponding content is loaded in the main content area

### 2.4 Breadcrumb Navigation

Breadcrumbs appear at the top of the content area:
```
Course Name > Module 1 > Section 1.2
```
**Common selectors:**
```
nav[aria-label*="breadcrumb" i]
.cds-Breadcrumb
ol[role="navigation"]
```

Each breadcrumb segment is a clickable link except the last (current page).

---

## 3. Video Player DOM Patterns

Coursera uses a custom video player embedded in the content area.

### 3.1 Video Player Element Structure

**How to identify the video player:**
- The player is typically wrapped in a `<div>` with role or class indicating "video player"
- Contains an HTML5 `<video>` element inside
- Player controls are below or overlaid on the video

**Common selectors:**
```
video[data-testid="video-player"]
video.vjs-tech
.cds-VideoPlayer
[data-testid="video-player-container"]
video[src]              <!-- The actual <video> element -->
```

**Structure overview:**
```
<div class="video-player-container">
  <video src="..." />
  <div class="video-controls">
    <button class="play-pause">...</button>
    <div class="progress-bar">...</div>
    <span class="time-display">2:34 / 10:00</span>
    <button class="speed-control">1x</button>
    <button class="fullscreen">⛶</button>
  </div>
</div>
```

### 3.2 Play/Pause Button

**How to identify:**
- Button with aria-label "Play" or "Pause"
- Contains a play triangle (▶) or pause bars (⏸) icon
- Located in the control bar at the bottom of the video

**Common selectors:**
```
button[aria-label="Play"]
button[aria-label="Pause"]
[data-testid="play-pause-button"]
.cds-PlayPauseButton
```

**How to toggle:** Click the button. If the video is playing, clicking pauses it (label changes to "Pause"). If paused, clicking plays (label changes to "Play").

### 3.3 Progress Bar

**How to identify:**
- A horizontal bar showing video progress
- Usually a `<div>` or `<input type="range">` element
- Contains a "filled" portion (current progress) and "empty" portion (remaining)

**Common selectors:**
```
input[type="range"][aria-label*="progress" i]
[data-testid="progress-bar"]
.cds-ProgressBar
.cds-SeekBar
```

**How to read current time and total time:**
- Look for a time display element near the progress bar
- Format is typically `MM:SS / MM:SS` (current / total)
- May also be `HH:MM:SS / HH:MM:SS` for longer videos
- The `<video>` element's `currentTime` and `duration` JavaScript properties provide exact values

**Via JavaScript (most reliable):**
```javascript
const video = document.querySelector('video');
const currentTime = video.currentTime;  // seconds
const duration = video.duration;        // seconds
```

### 3.4 Speed Control

**How to identify:**
- A button showing the current playback speed (e.g., "1x", "1.5x", "2x")
- Located in the control bar

**Common selectors:**
```
button[aria-label*="speed" i]
[data-testid="speed-control"]
.cds-SpeedControl
```

**How to detect current speed:** Read the button's text content (e.g., "1x", "1.25x", "1.5x", "2x").

**How to cycle through options:**
1. Click the speed button to open a dropdown/menu of speed options
2. Available speeds are typically: 0.5x, 0.75x, 1x (Normal), 1.25x, 1.5x, 1.75x, 2x
3. Click the desired speed option in the dropdown
4. The button text updates to show the new speed

**Via JavaScript (most reliable):**
```javascript
const video = document.querySelector('video');
video.playbackRate = 2;  // Set to 2x speed
```

### 3.5 Fullscreen Button

**How to identify:**
- Button with aria-label "Fullscreen" or "Exit fullscreen"
- Contains a fullscreen icon (expand arrows)

**Common selectors:**
```
button[aria-label*="fullscreen" i]
button[aria-label*="Full screen" i]
[data-testid="fullscreen-button"]
```

### 3.6 Detecting Video Completion

**How to identify completion:**
1. **Progress at 100%:** The progress bar is fully filled; `video.currentTime >= video.duration * 0.99`
2. **"Completed" label:** A checkmark or "Completed" text appears near the video
3. **"Mark as Complete" button appears:** If auto-completion isn't enabled, a button prompts the user
4. **Sidebar update:** The corresponding sidebar item shows a checkmark

**JavaScript check:**
```javascript
const video = document.querySelector('video');
const isComplete = video.currentTime >= video.duration * 0.99;
```

### 3.7 "Mark as Complete" Button

**When it appears:**
- After a video finishes playing (progress near 100%)
- May also appear immediately for shorter content
- Some courses auto-mark; others require manual clicking

**How to identify:**
- Button with text "Mark as Complete", "Mark Complete", or "Complete & Continue"
- May be below the video player or in a notification bar

**Common selectors:**
```
button[data-testid="mark-complete"]
button:has-text("Mark as Complete")
button:has-text("Mark Complete")
button:has-text("Complete & Continue")
```

### 3.8 "Go to Next Item" Button

**How to identify:**
- Button/link with text "Next", "Go to next item", or "Continue"
- Appears after video completion or near the bottom of the content area
- Navigates to the next section in the course

**Common selectors:**
```
button:has-text("Next")
a:has-text("Go to next item")
[data-testid="next-item-button"]
```

### 3.9 Audio-Only Content

Some content is audio-only (e.g., podcast-style lectures):
- Same player structure as video but no video track
- The `<video>` element may have no visual content, or an audio-specific player is used
- Controls are the same (play/pause, progress, speed)
- Look for an audio waveform visualization or just a player bar without video area

---

## 4. Quiz and Assessment DOM Patterns

### 4.1 Quiz Page Layout

**URL pattern:** `https://www.coursera.org/learn/<course-slug>/quiz/...` or embedded within the course content flow.

**How to identify a quiz page:**
- Page title may contain "Quiz", "Practice Quiz", "Graded Quiz", or "Assessment"
- Content area shows questions in sequence
- Navigation buttons at the bottom ("Submit", "Check your answer", "Next question")

**Structure:**
```
<div class="quiz-container">
  <h1>Quiz Title</h1>
  <div class="quiz-progress">Question 1 of 10</div>
  <div class="question-container">
    <p class="question-text">What is ...?</p>
    <div class="answer-options">
      <!-- Radio buttons, checkboxes, or text inputs -->
    </div>
  </div>
  <div class="quiz-actions">
    <button>Submit</button>
  </div>
</div>
```

### 4.2 Question Containers

**How to identify:**
- Each question is wrapped in a container `<div>` or `<fieldset>`
- Contains the question text (usually a `<p>` or `<span>`)
- Contains answer input elements below the question text
- May show question number ("Question 1", "Q1")

**Common selectors:**
```
[data-testid="question-container"]
.quiz-question
fieldset[role="group"]
div[class*="question"]
```

### 4.3 Radio Buttons (Single-Choice)

**How to identify:**
- Questions with multiple options where only one can be selected
- Options rendered as `<input type="radio">` elements or custom-styled radio buttons
- Each option has a label with the answer text

**Common selectors:**
```
input[type="radio"]
[data-testid="radio-option"]
.cds-RadioButton
[role="radio"]
```

**How to select an answer:** Click the radio button or its associated label text.

### 4.4 Checkboxes (Multi-Select)

**How to identify:**
- Questions where multiple answers can be selected
- Instructions typically say "Select all that apply"
- Options rendered as `<input type="checkbox">` or custom checkbox elements

**Common selectors:**
```
input[type="checkbox"]
[data-testid="checkbox-option"]
.cds-Checkbox
[role="checkbox"]
```

**How to select answers:** Click each checkbox for the desired answers.

### 4.5 Text Input (Fill-in-the-Blank)

**How to identify:**
- Questions with a text input field for typing an answer
- May appear as: "The answer is ______" with an input field
- Input field may be inline within the question text or below it

**Common selectors:**
```
input[type="text"]
textarea
[data-testid="text-input"]
.cds-TextInput
```

### 4.6 Honor Code Dialog

**When it appears:** Before starting a graded quiz or exam, Coursera may show an honor code acknowledgment dialog.

**How to identify:**
- A modal/dialog overlay
- Contains text about academic integrity / honor code
- Has a checkbox to agree ("I agree to the Honor Code")
- Has a "Continue" or "Start" button (disabled until checkbox is checked)

**How to dismiss:**
1. Find the honor code checkbox
2. Click the checkbox to check it
3. The "Continue" / "Start" button becomes enabled
4. Click the button to proceed

**Common selectors:**
```
[data-testid="honor-code-dialog"]
.cds-Modal
dialog[open]
input[type="checkbox"]        <!-- Inside the dialog -->
button:has-text("Continue")   <!-- Inside the dialog -->
button:has-text("Start")      <!-- Inside the dialog -->
```

### 4.7 "Start" Button for Graded Assignments

**How to identify:**
- Button with text "Start", "Begin Quiz", "Start Quiz", or "Take Quiz"
- May appear on a preview/intro page before the actual quiz questions
- Some graded assessments show time limits and attempt counts on this page

### 4.8 "Check Your Answer" vs. "Submit" Buttons

| Button | When It Appears | Behavior |
|--------|----------------|----------|
| **"Check your answer"** | Practice quizzes | Immediately shows if answer is correct/incorrect, allows retry |
| **"Submit"** | Graded quizzes | Submits the entire quiz for grading |
| **"Submit Quiz"** | Graded quizzes (alternative label) | Same as Submit |
| **"Next"** | Multi-page quizzes | Moves to next question (answers saved) |

**Common selectors:**
```
button:has-text("Check your answer")
button:has-text("Submit")
button:has-text("Submit Quiz")
button[data-testid="submit-button"]
```

### 4.9 Quiz Results Page

**How to identify:**
- Shows a score (e.g., "8/10" or "80%")
- May show which questions were correct/incorrect
- Has a "Continue" or "Back to course" button
- May show "Pass" or "Fail" status

**How to read the score:**
- Look for text containing a percentage or fraction
- Common format: "You scored X out of Y" or "X%"
- May be in a prominent display element at the top of the results

---

## 5. Navigation Patterns

### 5.1 Side Menu Structure

The side menu (sidebar) is the primary navigation within a course. It lists:

- **Modules/Weeks** — collapsible sections
- **Sections within modules** — individual content items (videos, readings, quizzes, labs)

Each section item is a clickable link that loads that content in the main area.

**How to click a specific section:**
1. Find the sidebar
2. Locate the desired module (may need to expand it by clicking the module header)
3. Click the specific section link within that module
4. The main content area updates to show that section

### 5.2 Completion Indicators in the Menu

| Icon | Meaning |
|------|---------|
| ✓ (green) | Completed |
| ○ (empty circle) | Not started |
| ◐ (half circle) | In progress |
| ▶ (play icon) | Currently viewing |

### 5.3 "Next" / "Previous" Buttons

**⚠️ Recommendation:** Avoid using Next/Previous buttons for navigation. They may skip content or behave unexpectedly. Instead, navigate directly via the sidebar.

**How to identify (if needed):**
- "Next" button: appears at the bottom of content, navigates to next section
- "Previous" button: navigates to previous section
- May also appear as arrow buttons (→ / ←)

**Common selectors:**
```
button:has-text("Next")
button:has-text("Previous")
a[aria-label="Next"]
a[aria-label="Previous"]
[data-testid="next-button"]
[data-testid="previous-button"]
```

### 5.4 "Back to Course" Links

**How to identify:**
- Link or button with text "Back to course", "Return to course", or "Course home"
- Often in the top navigation or breadcrumbs
- Navigates to the course overview/landing page

### 5.5 Detecting Page Type

**How to determine what type of content is currently displayed:**

| Page Type | How to Identify |
|-----------|----------------|
| **Video** | `<video>` element present, video player container visible |
| **Reading** | Long-form text content, no video player, may have images and formatted text |
| **Quiz** | Question containers with radio/checkbox inputs, "Submit" or "Check" buttons |
| **Lab** | Embedded iframe or sandbox environment, "Launch Lab" button |
| **Discussion** | Thread-based UI, reply buttons, user avatars |
| **Peer Review** | Rubric display, "Submit Review" button, other students' work to evaluate |

**Quick detection via JavaScript:**
```javascript
// Check for video
const hasVideo = !!document.querySelector('video');

// Check for quiz
const hasQuiz = !!document.querySelector('[data-testid="question-container"], .quiz-question, fieldset[role="group"]');

// Check for reading (no video, no quiz, main content area has text)
const hasReading = !hasVideo && !hasQuiz && !!document.querySelector('article, .reading-content, [data-testid="reading-content"]');
```

---

## 6. Login and Session Patterns

### 6.1 Login Page

**URL:** `https://www.coursera.org/?authMode=login` or `https://accounts.google.com/...` (Google SSO)

**How to identify:**
- Page shows email/password input fields
- "Log In" or "Sign In" button
- Social login options (Google, Apple, Facebook)
- "Forgot Password?" link

**Common selectors:**
```
input[name="email"]
input[name="password"]
input[type="email"]
input[type="password"]
button[type="submit"]
button:has-text("Log In")
button:has-text("Sign In")
```

### 6.2 Detecting If User Is Logged In

**How to identify an authenticated session:**
1. **Avatar/profile icon** — in the top-right corner, shows user's profile picture or initial
2. **Profile menu** — clicking the avatar shows dropdown with "Profile", "Settings", "Log Out"
3. **No login prompts** — dashboard shows enrolled courses instead of login form
4. **URL check** — `https://www.coursera.org/learner/` loads without redirect

**Common selectors for logged-in state:**
```
[data-testid="user-menu"]
[aria-label*="profile" i]
[aria-label*="account" i]
.cds-UserMenu
button[aria-haspopup="menu"]    <!-- Top-right menu button -->
```

### 6.3 Session Expired Detection

**How to identify:**
- Unexpected redirect to login page
- Modal/dialog saying "Your session has expired" or "Please log in again"
- API calls returning 401/403 errors
- Content that was visible suddenly disappears or shows error states

**Common selectors:**
```
[data-testid="session-expired"]
.cds-SessionExpired
dialog:has-text("session")
```

**Recovery:** Navigate to login page and re-authenticate.

### 6.4 Cookie Consent Dialogs

**How to identify:**
- A banner or modal at the bottom/top of the page
- Text about cookies and privacy
- "Accept All", "Accept", or "Got it" button
- May have "Manage Preferences" or "Reject All" options

**Common selectors:**
```
[data-testid="cookie-banner"]
[id*="cookie" i]
[class*="cookie" i]
[aria-label*="cookie" i]
button:has-text("Accept All")
button:has-text("Accept")
button:has-text("Got it")
```

**How to dismiss:** Click "Accept All" or "Accept" button.

---

## 7. Common Popups and Dialogs

### 7.1 Honor Code Dialogs

**When:** Before graded quizzes, exams, or peer-reviewed assignments.

**How to identify:**
- Modal overlay with text about academic integrity
- Checkbox to agree
- "Continue" or "Start" button

**How to dismiss:**
1. Check the agreement checkbox
2. Click "Continue" / "Start"

**See also:** [Section 4.6 — Honor Code Dialog](#46-honor-code-dialog)

### 7.2 Cookie Consent

**When:** First visit or after cookies are cleared.

**How to dismiss:** Click "Accept All" or "Accept".

**See also:** [Section 6.4 — Cookie Consent Dialogs](#64-cookie-consent-dialogs)

### 7.3 "Rate This Course" Prompts

**When:** Periodically during course progress, or after completing a module.

**How to identify:**
- Modal dialog asking to rate the course
- Star rating widget (1-5 stars)
- Optional text feedback field
- "Submit" and "Skip" / "Not Now" buttons

**Common selectors:**
```
[data-testid="rating-dialog"]
.cds-Modal:has-text("rate")
button:has-text("Skip")
button:has-text("Not Now")
button:has-text("Submit")
```

**How to dismiss:**
- Click "Skip", "Not Now", or "No Thanks" to dismiss without rating
- Or provide a rating and click "Submit"

### 7.4 Notification Popups

**When:** Various triggers — new course recommendations, deadline reminders, achievement badges.

**How to identify:**
- Toast notifications (small popups in corner)
- Notification bell icon with badge count
- In-app notification panel

**How to dismiss:**
- Toast: wait for auto-dismiss or click the X/close button
- Notification panel: click outside or click the close button
- Bell icon: click to view, then close

**Common selectors:**
```
[data-testid="notification-toast"]
.cds-Toast
[role="alert"]
[role="status"]
button[aria-label*="close" i]
button[aria-label*="dismiss" i]
```

### 7.5 Generic Dialog Dismissal Strategy

When encountering any unfamiliar popup/dialog:

1. **Check for a close button:** Look for `[aria-label="Close"]`, `button[class*="close"]`, or an X icon button
2. **Check for "Skip" / "Dismiss" / "Not Now" buttons:** Click the least-committal action
3. **Check for an overlay backdrop:** Clicking outside the modal may dismiss it (if not a forced dialog)
4. **Press Escape key:** Some dialogs respond to `Escape` key
5. **If it's a required dialog:** Read the content and take the minimum required action (e.g., check a box and continue)

---

## Appendix: General Tips for Coursera Automation

### Prefer JavaScript Evaluation Over Clicking
Many UI elements can be controlled more reliably via JavaScript:
```javascript
// Set video speed
document.querySelector('video').playbackRate = 2;

// Check if video is complete
document.querySelector('video').currentTime >= document.querySelector('video').duration * 0.99;

// Scroll to bottom of page
window.scrollTo(0, document.body.scrollHeight);
```

### Wait for Content to Load
Coursera is a single-page application (SPA). Content loads dynamically:
- After clicking a navigation link, wait for the new content to render
- Look for loading spinners to disappear
- Check that the URL has changed (for navigation)
- Verify the expected content element exists before interacting

### Handling SPAs (Single Page Application)
- URL changes without full page reload
- Content area updates dynamically
- The sidebar may persist while main content changes
- After navigation, re-query DOM elements (don't cache references)

### Common ARIA Attributes to Leverage
Coursera uses ARIA attributes for accessibility, which are also useful for automation:
- `role="button"` — clickable elements
- `role="checkbox"` / `role="radio"` — form controls
- `role="dialog"` — modal dialogs
- `role="navigation"` — nav sections
- `aria-label` — descriptive labels for buttons/icons
- `aria-expanded` — collapsible sections
- `aria-selected` — active/selected tab or menu item
- `aria-checked` — checkbox/radio state
