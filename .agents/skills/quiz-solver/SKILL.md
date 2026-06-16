---
name: quiz-solver
description: Use when solving quizzes on the Digilians LMS (lms.digilians.gov.eg). Triggered by user saying "Quiz Solver" or "solve this quiz". Opens browser, navigates to LMS, waits 1 minute for user to log in and open quiz, then auto-solves without waiting for "start".
---

# Quiz Solver

Automates quiz solving on `lms.digilians.gov.eg`. Fully autonomous — just say "Quiz Solver" and it handles everything. Opens browser, gives you 1 minute to log in and open a quiz, then automatically extracts and submits all answers.

## Flow

```
User says "Quiz Solver"
        │
        ▼
Launch Chrome + navigate to lms.digilians.gov.eg
        │
        ▼
Start 1-minute countdown (user logs in + opens quiz)
        │
        ▼
After 1 minute: check if a quiz attempt is open
        │
        ├─ Quiz found → continue ▼
        ├─ No quiz → check again in 30s (up to 3 retries)
        └─ Still no quiz → tell user to open one
        │
        ▼
PHASE 1: EXTRACT (1 JS call, ~2s)
  Auto-detect question count from quiz nav
  Fetch all pages via JS fetch() in parallel
  Parse question text + radio VALUES + option text + hidden form fields
        │
        ▼
PHASE 2: COMPUTE ANSWERS (instant)
  Agent reads all questions + options
  Determines correct answers
  Builds answer map: { inputName → radioValue }
        │
        ▼
PHASE 3: SUBMIT (1 JS call, ~1-2s per question)
  For each page: fetch HTML → extract form data → POST answer
  Zero browser navigation — stays on current page the whole time
  Progress bar + title update
        │
        ▼
Done. User reviews and clicks "Submit all and finish".
```

## Step 1: Open Browser + LMS

When the user says "Quiz Solver":

1. Start the browser: `openclaw browser start`
2. Open the LMS: `openclaw browser open "https://lms.digilians.gov.eg"`
3. Tell the user: "LMS is open. You have 1 minute to log in and open a quiz. I'll start solving automatically."
4. Wait 1 minute (use `exec` with a sleep or timer)

## Step 2: Detect Quiz Attempt

After the 1-minute wait, check if the user has opened a quiz:

```bash
openclaw browser evaluate --fn "(() => {
  const url = new URL(window.location.href);
  const attempt = url.searchParams.get('attempt');
  const cmid = url.searchParams.get('cmid');
  if (attempt && cmid) {
    return { found: true, attempt, cmid, url: url.href };
  }
  // Check if we're on a quiz page without attempt param
  const quizLink = document.querySelector('a[href*=\"attempt.php\"]');
  if (quizLink) {
    return { found: false, hint: 'Quiz page detected but no attempt started', link: quizLink.href };
  }
  return { found: false, hint: 'No quiz detected', url: url.href };
})()"
```

**If quiz found:** proceed to Phase 1 (extract).
**If no quiz found:** wait 30 seconds, check again. Up to 3 retries. If still no quiz, tell the user to open one and say "start".

## Step 3: Phase 1 — Extract All Questions

Script: `extract.js` in this skill directory.

Run via:
```powershell
$fn = Get-Content "~/.agents/skills/quiz-solver/extract.js" -Raw
openclaw browser evaluate --fn $fn
```

Returns `{ totalDetected, extracted, failed, failures, sesskey, questions }`.
Each question: `{ page, question, inputName, options, optionCount, hiddenFields }`.
Each option: `{ index, value, text }` — `value` is the actual radio value attribute.

## Step 4: Phase 2 — Compute Answers

Agent reads each question and determines the correct answer. Build an answer map:

```json
{
  "q59433:13_answer": "0",
  "q59433:5_answer": "1",
  "q59433:11_answer": "0"
}
```

Keys = input names. Values = radio `value` attribute (usually `"0"`, `"1"`, `"2"`, `"3"`).

**⚠️ Use the `value` field from options, not the index.**

**Answering guidelines:**
- CNN/Deep Learning: convolutional layers, activation functions, pooling, weight sharing, padding, stride, filters, feature maps
- RNN/LSTM: sequential data, hidden states, gates, vanishing/exploding gradients, embeddings
- True/False: carefully evaluate the statement
- Calculations: compute precisely
- When uncertain: pick the most technically precise answer

## Step 5: Phase 3 — Submit All Answers

Script: `auto-pilot.js` in this skill directory.

Navigate to page 0 first, then inject with the answer map:

```powershell
$fn = Get-Content "~/.agents/skills/quiz-solver/auto-pilot.js" -Raw
openclaw browser evaluate --fn $fn
```

What it does:
- For each page: fetch HTML → extract form data → POST answer (no browser navigation)
- Green progress bar at top + title update
- On completion: title → `[DONE] Quiz Solver`
- Does NOT auto-submit — user reviews on summary page

## Step 6: Tell User

After submission completes, tell the user:
- How many questions were answered
- Any failures
- Navigate to summary page to review and click "Submit all and finish"

## Monitoring

```bash
openclaw browser console --level log
```
Look for `[QSV2] p0 ✓ q59433:13_answer=0`, etc.

## Important Notes

- **Fully autonomous** — no "start" command needed after initial trigger
- **1-minute countdown** — user has time to log in and open quiz
- **Auto-retry** — if no quiz detected, checks every 30s up to 3 times
- **Answer values must be radio `value` attributes**, not option indices
- **No browser navigation** during submission — fetch POST only
- **Does NOT auto-submit** — user reviews and clicks Submit manually
- **Site-specific** to `lms.digilians.gov.eg` Moodle quizzes

## Speed

| Phase | Time |
|-------|------|
| Open browser + LMS | ~3s |
| Wait for user | 60s |
| Extract | ~2s |
| Compute | instant |
| Submit (17Q) | ~20-30s |
| **Total** | **~90s** |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| No quiz after 1 min | User may be slow — retry or ask them to say "start" |
| `ANSWERS map is empty` | Answer map wasn't injected — check extract output |
| `VALIDATION FAILED` | Re-extract — input names may have changed |
| HTTP errors | Session expired — user needs to log in again |
| Wrong answers | Verify radio `value` attribute, not option index |
