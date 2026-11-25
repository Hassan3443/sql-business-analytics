(async function () {
  const $ = s => document.querySelector(s);
  const status = $('#status');
  status.textContent = 'loading database...';
  const [SQL, queries, dbBuf] = await Promise.all([
    initSqlJs({ locateFile: f => 'vendor/' + f }),
    fetch('queries.json').then(r => r.json()),
    fetch('sales.db').then(r => r.arrayBuffer())
  ]);
  const db = new SQL.Database(new Uint8Array(dbBuf));
  let current = null, last = null;

  $('#list').innerHTML = queries.map(q => `<button data-id="${q.id}"><span>${String(q.number).padStart(2, '0')}</span>${q.title}</button>`).join('');
  $('#list').onclick = e => { const b = e.target.closest('button'); if (b) select(b.dataset.id); };

  function select(id) {
    current = queries.find(q => q.id === id);
    document.querySelectorAll('#list button').forEach(b => b.classList.toggle('on', b.dataset.id === id));
    $('#qtitle').textContent = `${String(current.number).padStart(2, '0')} ${current.title}`;
    $('#qdesc').textContent = current.description;
    $('#sql').value = current.sql;
    history.replaceState(null, '', '#' + id);
    run();
  }

  const isNum = v => typeof v === 'number';
  const fmt = v => v === null ? 'NULL' : isNum(v) ? (Number.isInteger(v) ? v.toLocaleString('en-US') : v.toLocaleString('en-US', { maximumFractionDigits: 2 })) : String(v).replace(/[&<>]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]));

  function run() {
    $('#err').textContent = '';
    const t0 = performance.now();
    try {
      const res = db.exec($('#sql').value);
      if (!res.length) { last = null; $('#res').innerHTML = ''; $('#meta').textContent = 'Statement ran, no rows returned'; $('#chartcard').style.display = 'none'; return; }
      last = res[res.length - 1];
      const ms = Math.max(1, Math.round(performance.now() - t0));
      $('#meta').textContent = `${last.values.length} row${last.values.length === 1 ? '' : 's'} in ${ms} ms`;
      const numCols = last.columns.map((_, i) => last.values.some(r => isNum(r[i]))).map((x, i) => x ? i : -1).filter(i => i >= 0);
      $('#res').innerHTML = `<thead><tr>${last.columns.map((c, i) => `<th class="${numCols.includes(i) ? 'n' : ''}">${c}</th>`).join('')}</tr></thead><tbody>${last.values.slice(0, 300).map(r => `<tr>${r.map((v, i) => `<td class="${isNum(v) ? 'n' : ''}">${fmt(v)}</td>`).join('')}</tr>`).join('')}</tbody>`;
      chart(numCols);
    } catch (e) { $('#err').textContent = e.message; }
  }

  function chart(numCols) {
    const card = $('#chartcard');
    const labelIdx = last.columns.findIndex((_, i) => !numCols.includes(i));
    const metrics = numCols.filter(i => i !== 0 || labelIdx === -1 ? true : true);
    if (!numCols.length || last.values.length < 2 || last.values.length > 40) { card.style.display = 'none'; return; }
    card.style.display = '';
    const sel = $('#metric'); const prev = sel.value; const sameShape = false;
    sel.innerHTML = numCols.map(i => `<option value="${i}">${last.columns[i]}</option>`).join('');
    const names = numCols.map(i => last.columns[i]);
    const idLike = n => /(^|_)(id|rank|decile|quarter|line_items|days|number)($|_)/i.test(n);
    const pref = /revenue|value|total|share|pct|rate|orders|customers|count/i;
    let k = names.findIndex(n => !idLike(n) && /revenue|value|total|spend/i.test(n));
    if (k < 0) k = names.findIndex(n => !idLike(n) && pref.test(n));
    if (k < 0) k = names.findIndex(n => !idLike(n));
    const def = numCols[k >= 0 ? k : 0];
    sel.value = numCols.includes(+prev) && Array.from(sel.options).some(o => o.value === prev) && prev !== '' && sameShape ? prev : String(def);
    draw();
  }
  function draw() {
    const m = +$('#metric').value;
    const strCols = last.columns.map((c, i) => i).filter(i => i !== m && last.values.some(r => typeof r[i] === 'string'));
    const lab = r => (strCols.length ? strCols.slice(0, 2).map(i => r[i]).join(' + ') : r[0]);
    const rows = last.values.map(r => [String(lab(r)), r[m] ?? 0]);
    const max = Math.max(...rows.map(r => Math.abs(r[1])), 1);
    $('#chart').innerHTML = rows.map(([l, v]) => `<div class="bar-row"><span title="${l}">${l}</span><div class="tr"><div class="fl" style="width:${Math.abs(v) / max * 100}%"></div></div><b>${fmt(v)}</b></div>`).join('');
  }

  $('#metric').onchange = draw;
  $('#run').onclick = run;
  $('#reset').onclick = () => { $('#sql').value = current.sql; run(); };
  $('#sql').addEventListener('keydown', e => { if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') { e.preventDefault(); run(); } if (e.key === 'Tab') { e.preventDefault(); const t = e.target, s = t.selectionStart; t.value = t.value.slice(0, s) + '    ' + t.value.slice(t.selectionEnd); t.selectionStart = t.selectionEnd = s + 4; } });
  $('#dl').onclick = () => { if (!last) return; const esc = v => v === null ? '' : /[",\n]/.test(String(v)) ? '"' + String(v).replace(/"/g, '""') + '"' : v; const csv = [last.columns.join(','), ...last.values.map(r => r.map(esc).join(','))].join('\n'); const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([csv], { type: 'text/csv' })); a.download = (current ? current.id : 'result') + '.csv'; a.click(); };
  status.textContent = 'database ready';
  select(location.hash.slice(1) && queries.some(q => q.id === location.hash.slice(1)) ? location.hash.slice(1) : '12_customer_spend_deciles');
})();
