// Quiz Detector - Check if a quiz attempt is currently open
// Returns { found, attempt, cmid, url } or { found, false, hint }
() => {
  const url = new URL(window.location.href);

  // Check if we're already on a quiz attempt page
  const attempt = url.searchParams.get('attempt');
  const cmid = url.searchParams.get('cmid');
  if (attempt && cmid) {
    // Check for quiz-specific elements on the page
    const hasQuizNav = !!document.querySelector('.qn_buttons, .quiznavigation');
    const hasQuestion = !!document.querySelector('.qtext, .answer');
    return {
      found: true,
      onAttemptPage: true,
      attempt: attempt,
      cmid: cmid,
      hasQuizNav: hasQuizNav,
      hasQuestion: hasQuestion,
      url: url.href
    };
  }

  // Check if we're on a quiz page with a "Start attempt" or "Continue attempt" button
  const startBtn = document.querySelector('input[value*="Start attempt"], input[value*="Continue attempt"], button:has-text("Start attempt"), a:has-text("Continue attempt")');
  if (startBtn) {
    return {
      found: false,
      hint: 'Quiz page detected with start button — attempt not yet started',
      buttonText: startBtn.textContent || startBtn.value,
      url: url.href
    };
  }

  // Check for quiz links on the page (course page or dashboard)
  const quizLinks = document.querySelectorAll('a[href*="quiz/view.php"], a[href*="mod/quiz"]');
  if (quizLinks.length > 0) {
    const links = [];
    quizLinks.forEach(a => {
      links.push({ text: a.textContent.trim().substring(0, 60), href: a.href });
    });
    return {
      found: false,
      hint: 'Quiz links found on page — user may need to click one',
      quizLinks: links.slice(0, 5),
      url: url.href
    };
  }

  return {
    found: false,
    hint: 'No quiz detected on current page',
    url: url.href
  };
}
