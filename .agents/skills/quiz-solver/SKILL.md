---
name: quiz-solver
description: Use when solving quizzes on the Digilians LMS (lms.digilians.gov.eg). Triggered by user saying "Quiz Solver" or "solve this quiz". Launches browser, waits for user login, then auto-solves using fast batch-extract + auto-pilot technique.
---

# Quiz Solver

Automates quiz solving on `lms.digilians.gov.eg` using a two-phase approach: batch extract all questions, then inject a self-running auto-pilot. Works for any quiz size (10, 15, 20, 25, 30 questions). ~N+1 tool calls vs N×5+ with the naive approach.

## Flow

```
User says "Quiz Solver"
        │
        ▼
Launch Chrome (CDP, port 18800)
        │
        ▼
User logs in + opens quiz + starts attempt
        │
        ▼
User says "start"
        │
        ▼
PHASE 1: EXTRACT (1 JS call)
  Auto-detect question count from quiz nav
  Fetch all pages via JS fetch() in parallel
  Parse question text + options + input names
  Return structured data with error reporting
        │
        ▼
PHASE 2: COMPUTE ANSWERS
  Agent reads all questions
  Determines correct answers using DL/CNN knowledge
  Builds answer map: { inputName → optionIndex }
        │
        ▼
PHASE 3: AUTO-PILOT (1 JS call)
  Validate answer map against first question
  Inject MutationObserver with dedup guard
  Visual progress bar + title update
  Auto-answers all questions + handles submission
        │
        ▼
Done. User reviews and submits.
```

## Phase 1: Extract All Questions

Full script: `extract.js` in this skill directory.

Key behaviors:
- Auto-detects question count from quiz navigation panel
- Fetches all pages in parallel via `fetch()`
- Returns `{ totalDetected, extracted, failed, failures, questions }`
- Failed pages include error info (not silent nulls)

Run via:
```bash
openclaw browser evaluate --fn '(() => { /* paste extract.js body */ })()'
```

Parse the result. Each item in `questions` has: `{ page, question, inputName, options, optionCount }`.

## Phase 2: Compute Answers

Agent reads each question and determines the correct answer. Build an answer map:

```json
{
  "q36789_1": 0,
  "q36790_1": 2,
  "q36791_1": 1
}
```

Keys = input names from extraction. Values = 0-based index of correct option.

**Answering guidelines:**
- For CNN/Deep Learning quizzes: use knowledge of convolutional layers, activation functions, pooling, weight sharing, padding, stride, filters, feature maps
- For True/False: carefully evaluate the statement - most CNN concepts are True
- For calculation questions: compute precisely (filter params = k×k×C_in×C_out + C_out)
- When uncertain: pick the most technically precise answer

## Phase 3: Inject Auto-Pilot

Full script: `auto-pilot.js` in this skill directory.

**Before injecting:**
1. Navigate to page 0 (first question)
2. Paste your computed answer map into the `ANSWERS` object

**What the auto-pilot does:**
- Validates first question's radio name exists in answer map
- Shows a green progress bar at top of page
- Updates page title with `[Q/N] Quiz Auto-Solver` for easy monitoring
- Uses `waitForElement()` instead of magic timeouts
- Dedup guard prevents double-clicks from rapid DOM mutations
- On last question: answers but does NOT auto-submit (user reviews first)

Run via:
```bash
openclaw browser evaluate --fn '(() => { /* paste auto-pilot.js body with ANSWERS filled */ })()'
```

## Monitoring

**Console logs:**
```bash
openclaw browser console --level log
```
Look for `[QuizSolver] Q1/20 answered...`, `[QuizSolver] Q2/20 answered...`

**Visual indicator:** Green progress bar at top of page + title update `[5/20] Quiz Auto-Solver`

**If auto-pilot stops:** Check console for `[QuizSolver] WARNING: No answer for qXXX`. This means the answer map is missing a key.

## Important Notes

- **Always navigate to page 0 before injecting auto-pilot**
- **The auto-pilot handles navigation** - don't manually click anything after injection
- **Answer map uses input names** (like `q36789_1`), not question text - this is reliable
- **Validation step** checks first question before starting - catches key mismatches early
- **Last question is NOT auto-submitted** — user reviews and clicks “Submit all and finish”
- **Stuck detection** — if same question fails 3 times, auto-pilot stops with clear error (prevents infinite loop)
- **10s timeout** per page load — handles slow connections gracefully
- **Question count is dynamic** - extraction auto-detects from the quiz nav panel
- **This skill is site-specific** to `lms.digilians.gov.eg` Moodle quiz structure

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `ERROR: ANSWERS map is empty` | Paste answer map into ANSWERS object before injecting |
| `VALIDATION FAILED` | First question radio name not in answer map - re-extract or check keys |
| `WARNING: No answer for qXXX` | That question's input name is missing from answer map |
| Stuck on a page | Check console - likely missing answer key for that question |
| Page not loading | Verify attempt/cmid in URL are correct |
| Wrong question count | Extraction auto-detects from nav - if wrong, check quiz has started |
| Double-click issues | Dedup guard prevents this - if still happening, page is too fast |
| Auto-pilot stuck | After 3 retries on same question, auto-pilot stops with clear error. Check console for `STUCK` message |
| Timeout errors | Default is 10s per page. If consistently timing out, check network or server status |
