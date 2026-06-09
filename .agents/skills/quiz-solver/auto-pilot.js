// Phase 3: Auto-pilot quiz solver
// Fixes applied: P0 (last question), P1 (dedup, timeouts, validation), P2 (dead code, progress, label click)
() => {
  const ANSWERS = { /* PASTE ANSWER MAP HERE: { "q12345_1": 0, "q12346_1": 2, ... } */ };

  // --- Validation: check answer map is populated ---
  const answerKeys = Object.keys(ANSWERS);
  if (answerKeys.length === 0) return 'ERROR: ANSWERS map is empty. Paste answer map before injecting.';

  const totalQuestions = answerKeys.length;
  let currentQuestion = 0;
  let solving = false; // P1 dedup guard
  let lastRadioName = null; // P1: track current question for retry detection
  let retryCount = 0; // P1: retry counter
  const MAX_RETRIES = 3; // P1: give up after 3 failures on same question

  // --- P2: Visual progress overlay ---
  function showProgress(count, total) {
    let bar = document.getElementById('quiz-solver-progress');
    if (!bar) {
      bar = document.createElement('div');
      bar.id = 'quiz-solver-progress';
      bar.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:4px;background:#22c55e;z-index:99999;transition:width 0.3s;';
      document.body.appendChild(bar);
    }
    bar.style.width = ((count / total) * 100) + '%';
    document.title = '[' + count + '/' + total + '] Quiz Auto-Solver';
  }

  // --- P1: Wait for element to appear instead of magic timeout ---
  function waitForElement(selector, timeoutMs) {
    timeoutMs = timeoutMs || 10000; // P1: 10s default for slow connections
    return new Promise((resolve, reject) => {
      const existing = document.querySelector(selector);
      if (existing) return resolve(existing);

      const observer = new MutationObserver(() => {
        const el = document.querySelector(selector);
        if (el) { observer.disconnect(); resolve(el); }
      });
      observer.observe(document.body, { childList: true, subtree: true });

      setTimeout(() => { observer.disconnect(); reject(new Error('Timeout waiting for ' + selector)); }, timeoutMs);
    });
  }

  // --- P2: Click label if available, fall back to input ---
  function clickRadio(inputName, optionIndex) {
    const radios = document.querySelectorAll('input[name="' + inputName + '"]');
    if (!radios[optionIndex]) return false;

    // Try clicking the associated label first (better theme compatibility)
    const radio = radios[optionIndex];
    const label = radio.closest('label') || document.querySelector('label[for="' + radio.id + '"]');
    if (label) {
      label.click();
    } else {
      radio.click();
    }
    return true;
  }

  // --- Find and click the navigation button ---
  function clickNav() {
    const btns = document.querySelectorAll('button, input[type=submit]');
    for (const btn of btns) {
      const text = btn.textContent.trim().toLowerCase();
      // P0: On last question, click "Submit all and finish" instead of "Next"
      if (currentQuestion >= totalQuestions) {
        if (text.includes('submit all') || text.includes('finish attempt')) {
          btn.click();
          return 'submit';
        }
      } else {
        if (text.includes('next')) {
          btn.click();
          return 'next';
        }
      }
    }
    return null;
  }

  // --- Core solve function ---
  async function solveCurrent() {
    if (solving) return; // P1 dedup guard
    solving = true;

    try {
      // P1: Wait for question to be present
      await waitForElement('.answer input[type=radio]', 10000);

      const radios = document.querySelectorAll('.answer input[type=radio]');
      if (radios.length === 0) {
        console.log('[QuizSolver] No radio buttons found on page');
        return;
      }

      const radioName = radios[0].name;

      // P1: Detect stuck — same question failing repeatedly
      if (radioName === lastRadioName) {
        retryCount++;
        if (retryCount >= MAX_RETRIES) {
          console.log('[QuizSolver] STUCK: Same question (' + radioName + ') failed ' + MAX_RETRIES + ' times. Stopping auto-pilot.');
          console.log('[QuizSolver] Manual intervention needed. Check: answer map, page state, or button text.');
          showProgress(currentQuestion, totalQuestions); // keep progress visible
          return;
        }
        console.log('[QuizSolver] Retry ' + retryCount + '/' + MAX_RETRIES + ' on ' + radioName);
      } else {
        lastRadioName = radioName;
        retryCount = 0;
      }

      // P1: Validate answer map has this question
      if (ANSWERS[radioName] === undefined) {
        console.log('[QuizSolver] WARNING: No answer for ' + radioName + '. Skipping page.');
        clickNav();
        return;
      }

      const optionIndex = ANSWERS[radioName];
      const success = clickRadio(radioName, optionIndex);

      if (success) {
        currentQuestion++;
        showProgress(currentQuestion, totalQuestions);
        console.log('[QuizSolver] Q' + currentQuestion + '/' + totalQuestions + ' answered (' + radioName + ' → option ' + optionIndex + ')');

        // P0: Wait a beat for the click to register, then navigate
        await new Promise(r => setTimeout(r, 200));

        // P0: If this was the last question, don't navigate — let user submit manually
        if (currentQuestion >= totalQuestions) {
          console.log('[QuizSolver] All questions answered! Review and submit manually.');
          document.title = '[DONE] Quiz Auto-Solver — Review & Submit';
          return;
        }

        clickNav();

        // P1: Wait for next page to load
        await waitForElement('.qtext', 10000);
      }
    } catch (e) {
      console.log('[QuizSolver] Error: ' + e.message);
    } finally {
      solving = false;
    }
  }

  // --- P1: Validate first question matches answer map ---
  const firstRadios = document.querySelectorAll('.answer input[type=radio]');
  if (firstRadios.length > 0) {
    const firstName = firstRadios[0].name;
    if (ANSWERS[firstName] === undefined) {
      return 'VALIDATION FAILED: First question radio (' + firstName + ') not in answer map. Keys: ' + answerKeys.slice(0, 5).join(', ') + '...';
    }
    console.log('[QuizSolver] Validation passed. First question: ' + firstName + ' → option ' + ANSWERS[firstName]);
  }

  // --- Start ---
  solveCurrent();
  showProgress(0, totalQuestions);
  return 'QuizSolver auto-pilot injected. Validated. Solving ' + totalQuestions + ' questions...';
}
