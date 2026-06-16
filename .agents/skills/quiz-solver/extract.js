// Phase 1: Extract all quiz questions with radio VALUES + form data
// v2 - Returns question text, radio values, option text, hidden fields, sesskey
() => {
  const url = new URL(window.location.href);
  const attempt = url.searchParams.get('attempt');
  const cmid = url.searchParams.get('cmid');
  if (!attempt || !cmid) return { error: 'Missing attempt or cmid.', url: url.href };

  const pageUrl = url.origin + '/mod/quiz/attempt.php?attempt=' + attempt + '&cmid=' + cmid + '&page=';
  const parser = new DOMParser();

  async function extractPage(pageNum) {
    try {
      const resp = await fetch(pageUrl + pageNum, { credentials: 'include' });
      if (!resp.ok) return { page: pageNum, error: 'HTTP ' + resp.status };
      const html = await resp.text();
      const doc = parser.parseFromString(html, 'text/html');
      const qText = doc.querySelector('.qtext');
      const answerDiv = doc.querySelector('.answer');
      if (!qText || !answerDiv) return { page: pageNum, error: 'No question/answer block' };

      const radios = answerDiv.querySelectorAll('input[type=radio]');
      if (radios.length === 0) return { page: pageNum, error: 'No radio buttons' };

      const inputName = radios[0].name;

      // Extract options with ACTUAL radio values (not indices)
      const options = [];
      radios.forEach((radio, idx) => {
        const label = radio.closest('label') || doc.querySelector('label[for="' + radio.id + '"]');
        let text = '';
        if (label) {
          const flex = label.querySelector('.flex-fill, .d-flex');
          text = flex ? flex.textContent.trim() : label.textContent.trim();
        }
        options.push({ index: idx, value: radio.value, text: text });
      });

      // Extract ALL hidden form fields (needed for POST submission)
      const form = doc.querySelector('form');
      const hiddenFields = {};
      if (form) {
        form.querySelectorAll('input[type=hidden]').forEach(inp => {
          hiddenFields[inp.name] = inp.value;
        });
      }

      return {
        page: pageNum,
        question: qText.textContent.trim(),
        inputName: inputName,
        options: options,
        optionCount: radios.length,
        hiddenFields: hiddenFields
      };
    } catch (e) {
      return { page: pageNum, error: e.message };
    }
  }

  // Auto-detect question count from quiz navigation
  const navLinks = document.querySelectorAll('a[href*="page="]');
  let maxPage = 0;
  navLinks.forEach(a => {
    const m = a.href.match(/page=(\d+)/);
    if (m) maxPage = Math.max(maxPage, parseInt(m[1]));
  });
  const hasSummary = !!document.querySelector('a[href*="summary"]');
  const total = hasSummary ? maxPage + 1 : Math.max(navLinks.length, 1);
  const pages = Array.from({length: total}, (_, i) => i);

  return Promise.all(pages.map(extractPage)).then(results => {
    const ok = results.filter(r => !r.error);
    const fail = results.filter(r => r.error);
    const sesskey = ok[0]?.hiddenFields?.sesskey || null;
    return { totalDetected: total, extracted: ok.length, failed: fail.length, failures: fail, sesskey, questions: ok };
  });
}
