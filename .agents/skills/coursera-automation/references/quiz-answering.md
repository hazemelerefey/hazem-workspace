# Quiz Answering Strategy Reference

This reference documents the exact strategy for answering quizzes and assessments on Coursera. The agent reading this will see quiz questions on screen and needs to answer them correctly to pass courses.

---

## Section 1: Quiz Answering Workflow (Step-by-Step)

```
QUIZ ANSWERING WORKFLOW:
1. Detect quiz type: practice quiz, graded assignment, or module challenge
2. If honor code dialog appears → check the box and dismiss
3. If "Start" button appears → click it
4. For each question on the page:
   a. Read the question text carefully
   b. Read ALL answer options
   c. Determine answer strategy:
      - HIGH CONFIDENCE: Answer is obvious from course content → select immediately
      - MEDIUM CONFIDENCE: Uncertain → use elimination, look for clues in question text
      - LOW CONFIDENCE: Completely unsure → make best guess, note for review
   d. Select the answer (click radio/checkbox or type)
   e. If "Check answer" exists → click it, verify, then proceed
5. After all questions answered → look for "Submit" button
6. Check for honor code checkbox before submit
7. Submit the quiz
8. Check results:
   a. If passed → click "Continue" or "Next"
   b. If failed → check if retake is allowed, retake if yes
   c. If failed and no retake → log it, move to next section
```

### Detailed Pseudocode

```
function handleQuizPage():
    # Step 1: Detect quiz type
    quiz_type = detectQuizType()  # practice | graded | module_challenge
    log("Quiz type: " + quiz_type)

    # Step 2: Handle honor code dialog
    if elementExists("[data-testid='honor-code']") or elementExists("honor-code-checkbox"):
        click("honor-code-checkbox")
        click("dismiss-dialog")

    # Step 3: Click Start if present
    if elementExists("Start") or elementExists("Begin"):
        click("Start")
        waitForPageLoad()

    # Step 4: Answer each question
    questions = getAllQuestions()
    for question in questions:
        question_text = readText(question)
        options = getAnswerOptions(question)
        log("Q: " + question_text)
        log("Options: " + options)

        # Determine confidence and select answer
        answer, confidence = determineAnswer(question_text, options)
        selectAnswer(question, answer)

        # Check answer if button exists (practice quizzes)
        if elementExists("Check answer"):
            click("Check answer")
            waitForFeedback()

    # Step 5: Submit
    if elementExists("Submit"):
        # Step 6: Honor code check
        if elementExists("honor-code-checkbox"):
            click("honor-code-checkbox")
        click("Submit")
        waitForPageLoad()

    # Step 8: Check results
    score = getScore()
    passing = getPassingThreshold()

    if score >= passing:
        log("PASSED with " + score + "%")
        if elementExists("Continue"):
            click("Continue")
    else:
        log("FAILED with " + score + "% (need " + passing + "%)")
        handleRetake()
```

---

## Section 2: Question Type Handling

| Type | How to Identify | How to Answer |
|------|----------------|---------------|
| **Multiple Choice (single)** | Radio buttons present; text like "select one" or "choose one answer" | Click one radio button corresponding to the best answer |
| **Multiple Select** | Checkboxes present; text like "select all that apply" or "choose all that apply" | Click all applicable checkboxes; be thorough — missing one correct answer may fail the question |
| **Ordering / Drag-and-Drop** | Drag handles (⠿ or ☰ icons); text like "arrange in order" or "drag to reorder" | May require special DOM manipulation; **note as potential blocker** — try dragging via Playwright drag API or JS reorder |
| **Fill-in-the-Blank** | Text input fields (`<input type="text">`) embedded in the question | Type the exact answer; match case/format from course material; look for clues in surrounding content |
| **Matching** | Two columns of items with connecting lines; text like "match the following" | Click items in pairs to create matches; typically left column → right column |

### Handling Each Type in Detail

**Multiple Choice (Single)**
```python
# Find the radio button group for this question
radio_buttons = question.querySelectorAll("input[type='radio']")
# Select the one whose label matches our answer
for rb in radio_buttons:
    if rb.label == chosen_answer:
        rb.click()
```

**Multiple Select**
```python
# Find all checkboxes for this question
checkboxes = question.querySelectorAll("input[type='checkbox']")
# Select ALL that are correct
for cb in checkboxes:
    if cb.label in correct_answers:
        cb.click()
```

**Fill-in-the-Blank**
```python
# Find the text input field
input_field = question.querySelector("input[type='text']")
# Type the answer (match formatting from course material)
input_field.fill(answer)
```

**Matching**
```python
# Click first item in left column, then matching item in right column
left_items = question.querySelectorAll(".left-column .item")
right_items = question.querySelectorAll(".right-column .item")
for pair in answer_pairs:
    click(left_items[pair.left_index])
    click(right_items[pair.right_index])
```

**Ordering / Drag-and-Drop**
```python
# Attempt drag-and-drop via Playwright API
# This is a potential blocker — some Coursera drag implementations
# use custom JS that may not respond to standard drag events
drag_handles = question.querySelectorAll(".drag-handle")
for i, correct_position in enumerate(correct_order):
    drag_handles[i].dragTo(target_positions[correct_position])
# Fallback: attempt JS-based reorder if drag fails
```

---

## Section 3: Answer Confidence Strategies

| Confidence | Action | Time per Question |
|------------|--------|-------------------|
| **High (>90%)** | Select immediately | 2-3 seconds |
| **Medium (50-90%)** | Quick elimination, then select | 5-10 seconds |
| **Low (<50%)** | Extended analysis, use all clues | 10-20 seconds |
| **Unknown** | Best guess, note for review | 5 seconds |

### Confidence Decision Tree

```
function determineAnswer(question, options):
    # Try to find answer in course content
    course_answer = searchCourseContent(question)
    if course_answer:
        return course_answer, HIGH

    # Try elimination
    eliminated = []
    for option in options:
        if isObviouslyWrong(option, question):
            eliminated.append(option)

    remaining = options - eliminated
    if len(remaining) == 1:
        return remaining[0], HIGH
    elif len(remaining) == 2:
        return bestGuess(remaining, question), MEDIUM
    else:
        return bestGuess(options, question), LOW
```

### When to Spend More Time

- **Spend extra time when:**
  - Question has high point value
  - Quiz has few questions (each matters more)
  - You're near the passing threshold
  - The question is about a critical concept

- **Move quickly when:**
  - Practice quiz (no grade impact)
  - You're well above passing threshold
  - Question is straightforward fact recall

---

## Section 4: Common Answer Patterns in Coursera Courses

### General Patterns

1. **The longest answer is often correct** — but not always. Use this as a tiebreaker, not a primary strategy.
2. **"All of the above" is often correct** when it's an option — verify by checking if all other options are true.
3. **Look for keywords from the course material** in the answers — Coursera questions often reuse exact phrasing from lectures and readings.
4. **Process of elimination** — remove obviously wrong answers first to narrow your choices.
5. **If two answers are very similar**, one of them is likely correct — the subtle difference is the key.
6. **Questions often contain hints** about the answer — read the question text carefully for embedded clues.

### Course-Specific Patterns

- **Technical courses:** Answers often match exact terminology from the instructor's slides or code examples.
- **Data science / ML courses:** Pay attention to specific values, formulas, or algorithm names mentioned in lectures.
- **Business courses:** Look for frameworks or models mentioned in the course — answers often reference these by name.
- **Programming courses:** Code snippet answers often test syntax details — look for exact syntax from examples.

### Anti-Patterns to Avoid

- Don't always pick "All of the above" — verify it first.
- Don't always pick the longest answer — verify it first.
- Don't assume the first answer is correct just because it sounds right.
- Don't change answers unless you have a clear reason.

---

## Section 5: Quiz Edge Cases

| Edge Case | How to Handle |
|-----------|---------------|
| **Quiz has time limit** | Monitor remaining time displayed on screen; speed up if below 25% remaining; don't panic — rush only as last resort |
| **Quiz requires minimum score** | Track running score if visible; retake immediately if below threshold |
| **One question at a time vs all at once** | Handle both: if one-at-a-time, answer and click "Next" for each question; if all-at-once, answer all then submit |
| **"Back" button to change answers** | Use if you realize an earlier answer was wrong; review before final submit if allowed |
| **Quiz locks after submission** | No going back — be sure before submitting; double-check all answers |
| **Quiz allows review** | Go back and check answers before final submit; focus on low-confidence answers |
| **Honor code must be checked before EACH submission** | Always check the honor code box before submitting — it appears on every attempt |
| **Quiz has attempts limit** | Track attempts used; be more careful on later attempts; log remaining attempts |
| **Some quizzes show correct answers after submission** | Record wrong answers for retake strategy; use this info to improve on retakes |
| **Quiz has different questions on retake** | Can't rely on memorizing positions; focus on understanding concepts |
| **Quiz navigation skips questions** | Ensure all questions are answered before submitting; scroll through entire page |

### Time Management

```
function manageTime(remaining_time, total_time, questions_left):
    time_ratio = remaining_time / total_time
    if time_ratio < 0.10:
        log("CRITICAL: Less than 10% time remaining!")
        # Rush mode: best guess for all remaining questions
        RUSH_MODE = True
    elif time_ratio < 0.25:
        log("WARNING: Less than 25% time remaining")
        # Reduce per-question time to minimum
        MAX_TIME_PER_QUESTION = 3  # seconds
    elif time_ratio < 0.50:
        log("On track, but keep moving")
        MAX_TIME_PER_QUESTION = 10
    else:
        # Plenty of time
        MAX_TIME_PER_QUESTION = 20
```

---

## Section 6: Retake Strategy

```
RETAKES:
1. If quiz failed and retake allowed → immediately start retake
2. On retake, remember which answers were wrong (if shown)
3. Change wrong answers, keep correct ones
4. If failed after 2 retakes → skip, log for user
5. Never exceed the maximum number of attempts
```

### Retake Decision Flowchart

```
function handleRetake():
    if not retake_allowed:
        log("No retake available. Score: " + score + "%")
        moveToNextSection()
        return

    if attempts_used >= max_attempts:
        log("Maximum attempts reached (" + max_attempts + ")")
        log("Final score: " + score + "%")
        moveToNextSection()
        return

    log("Starting retake attempt " + (attempts_used + 1))

    # If correct answers were shown, use them
    if correct_answers_shown:
        rememberCorrectAnswers()

    click("Retake Quiz")
    handleQuizPage()  # Re-run the full quiz workflow
```

### Retake Memory Strategy

```
retake_memory = {}

function rememberCorrectAnswers():
    # Store which answers were correct/wrong for retake
    for question in last_quiz_results:
        if question.was_wrong:
            retake_memory[question.id] = {
                "wrong_answer": question.selected_answer,
                "correct_answer": question.correct_answer,
                "question_text": question.text
            }
        else:
            retake_memory[question.id] = {
                "correct_answer": question.selected_answer,
                "question_text": question.text
            }

function useRetakeMemory(question):
    if question.id in retake_memory:
        return retake_memory[question.id].correct_answer
    return None  # Fall back to normal strategy
```

---

## Summary: Quick Reference

**Before the quiz:**
- Detect quiz type
- Check honor code if prompted
- Click Start if needed

**During the quiz:**
- Read every question fully
- Read every answer option
- Use confidence strategy (High → select, Medium → eliminate, Low → guess)
- Select answers (radio/checkbox/input)
- Check answer if available (practice quizzes)

**After answering all questions:**
- Check for honor code checkbox
- Click Submit
- Review results

**If failed:**
- Check retake policy
- If retake allowed and attempts remaining → retake immediately
- Use wrong answer info for retake
- After 2+ failures or max attempts → log and move on

**Edge cases to always watch for:**
- Time limits
- Honor code checkboxes (every submission!)
- One-at-a-time vs all-at-once layouts
- Maximum attempt limits
