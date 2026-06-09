// Phase 1: Extract all quiz questions from Digilians LMS
// Fixes applied: P0 (auto-detect), P1 (error reporting), P2 (dead code removal)
() => {
  const url = new URL(window.location.href);
  const attempt = url.searchParams.get('attempt');
  const cmid = url.searchParams.get('cmid');
  if (!attempt || !cmid) return { error: 'Not on a quiz page. Missing attempt or cmid in URL.', url: window.location.href };

  const baseUrl = url.origin + '/mod/quiz/attempt.php?attempt=' + attempt + '&cmid=' + cmid + '&page=';
  const parser = new DOMParser();

  async function extractPage(pageNum) {
    try {
      const resp = await fetch(baseUrl + pageNum);
      if (!resp.ok) return { page: pageNum, error: 'HTTP ' + resp.status };
      const html = await resp.text();
      const doc = parser.parseFromString(html, 'text/html');
      const qText = doc.querySelector('.qtext');
      const answerDiv = doc.querySelector('.answer');
      if (!qText || !answerDiv) return { page: pageNum, error: 'No question or answer block found' };

      const radios = answerDiv.querySelectorAll('input[type=radio]');
      if (radios.length === 0) return { page: pageNum, error: 'No radio buttons found' };

      const inputName = radios[0].name;

      // Extract option text — try flex-fill first, then labels
      const options = [];
      const flexes = answerDiv.querySelectorAll('.flex-fill, .d-flex');
      flexes.forEach(f => {
        const t = f.textContent.trim();
        if (t.length > 0 && t.length < 500 && !t.match(/^Question \d+$/)) options.push(t);
      });

      if (options.length === 0) {
        const labels = answerDiv.querySelectorAll('label');
        labels.forEach(l => {
          const t = l.textContent.trim();
          if (t.length > 0) options.push(t);
        });
      }

      return {
        page: pageNum,
        question: qText.textContent.trim(),
        inputName: inputName,
        options: options,
        optionCount: radios.length
      };
    } catch (e) {
      return { page: pageNum, error: e.message };
    }
  }

  // Auto-detect question count from quiz navigation
  const navLinks = document.querySelectorAll('a[href*="page="]');
  let maxPage = 0;
  navLinks.forEach(a => {
    const match = a.href.match(/page=(\d+)/);
    if (match) maxPage = Math.max(maxPage, parseInt(match[1]));
  });
  const finishLink = document.querySelector('a[href*="summary"]');
  const total = finishLink ? maxPage + 1 : Math.max(navLinks.length, 1);

  const pages = Array.from({length: total}, (_, i) => i);
  return Promise.all(pages.map(extractPage)).then(results => {
    const successful = results.filter(r => !r.error);
    const failed = results.filter(r => r.error);
    return {
      totalDetected: total,
      extracted: successful.length,
      failed: failed.length,
      failures: failed,
      questions: successful
    };
  });
}
