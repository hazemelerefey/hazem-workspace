// Phase 3: Submit all answers via fetch POST (no browser navigation)
// v2 - Fetches each page, extracts form data, POSTs answer. ~10x faster than auto-pilot.
// Paste the ANSWERS map before injecting. Values must be radio VALUE attributes (usually "0","1","2","3").
() => {
  const ANSWERS = { /* PASTE ANSWER MAP: { "q59433:13_answer": "0", "q59433:5_answer": "1", ... } */ };

  const url = new URL(window.location.href);
  const attempt = url.searchParams.get('attempt');
  const cmid = url.searchParams.get('cmid');
  if (!attempt || !cmid) return { error: 'Missing attempt or cmid in URL.' };

  const answerKeys = Object.keys(ANSWERS);
  if (answerKeys.length === 0) return { error: 'ANSWERS map is empty.' };

  const parser = new DOMParser();
  const origin = url.origin;
  const totalPages = answerKeys.length;

  // Progress overlay
  function showProgress(count, total, phase) {
    let bar = document.getElementById('qs-progress');
    if (!bar) {
      bar = document.createElement('div');
      bar.id = 'qs-progress';
      bar.style.cssText = 'position:fixed;top:0;left:0;height:6px;background:#22c55e;z-index:99999;transition:width 0.3s;';
      document.body.appendChild(bar);
    }
    bar.style.width = ((count / total) * 100) + '%';
    document.title = '[' + phase + ' ' + count + '/' + total + '] Quiz Solver';
  }

  // Fetch a page, extract form data, POST with the answer
  async function solvePage(pageNum) {
    const pageUrl = origin + '/mod/quiz/attempt.php?attempt=' + attempt + '&cmid=' + cmid + '&page=' + pageNum;

    // 1. Fetch page HTML
    const resp = await fetch(pageUrl, { credentials: 'include' });
    if (!resp.ok) return { page: pageNum, error: 'HTTP ' + resp.status };
    const html = await resp.text();
    const doc = parser.parseFromString(html, 'text/html');

    // 2. Find radio input name
    const radios = doc.querySelectorAll('.answer input[type=radio]');
    if (radios.length === 0) return { page: pageNum, error: 'No radios' };
    const inputName = radios[0].name;

    // 3. Check answer exists
    if (ANSWERS[inputName] === undefined) return { page: pageNum, error: 'No answer for ' + inputName };
    const answerValue = ANSWERS[inputName];

    // 4. Build form data from hidden fields
    const formData = new URLSearchParams();
    const form = doc.querySelector('form');
    if (form) {
      form.querySelectorAll('input[type=hidden]').forEach(inp => {
        formData.set(inp.name, inp.value);
      });
    }

    // 5. Set answer + navigation
    formData.set(inputName, String(answerValue));
    formData.set('thispage', String(pageNum));
    formData.set('nextpage', pageNum >= totalPages - 1 ? '-1' : String(pageNum + 1));

    // 6. POST
    const postResp = await fetch(pageUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: formData.toString(),
      credentials: 'include'
    });

    return { page: pageNum, inputName, value: answerValue, status: postResp.status, ok: postResp.ok };
  }

  // Run all pages sequentially
  async function run() {
    const results = [];
    for (let i = 0; i < totalPages; i++) {
      showProgress(i, totalPages, 'Solving');
      const r = await solvePage(i);
      results.push(r);
      console.log('[QSV2] ' + (r.error ? 'ERR p' + i + ': ' + r.error : 'p' + i + ' ✓ ' + r.inputName + '=' + r.value));
    }
    showProgress(totalPages, totalPages, 'DONE');
    document.title = '[DONE] Quiz Solver — Review & Submit';
    return { total: totalPages, ok: results.filter(r => !r.error).length, fail: results.filter(r => r.error).length, details: results };
  }

  // Validate first question
  const firstRadios = document.querySelectorAll('.answer input[type=radio]');
  if (firstRadios.length > 0 && ANSWERS[firstRadios[0].name] === undefined) {
    return 'VALIDATION FAILED: ' + firstRadios[0].name + ' not in answer map';
  }

  return run();
}
