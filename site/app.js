(function () {
  const ua = navigator.userAgent;
  const isAndroid = /Android/i.test(ua);
  const isWindows = /Windows/i.test(ua);
  const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

  document.getElementById('detected').textContent = isAndroid
    ? 'Detectamos tu Android'
    : isWindows ? 'Detectamos tu Windows' : 'Disponible para Android y Windows';

  // Aparición al hacer scroll
  const io = 'IntersectionObserver' in window
    ? new IntersectionObserver((es) => es.forEach((e) => { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } }), { threshold: .12 })
    : null;
  document.querySelectorAll('.card,.steps article,.finn-states,.devices,.stats>div,.why article,.how,.lists article,.qa details').forEach((el) => {
    el.classList.add('rev');
    io ? io.observe(el) : el.classList.add('in');
  });

  // Etiqueta de cada archivo según su nombre
  function describe(name) {
    if (/windows/i.test(name)) return { rank: 0, os: 'windows', title: 'Windows (ZIP)', sub: 'Descomprimí y abrí altfin.exe' };
    if (/arm64/i.test(name)) return { rank: 1, os: 'android', title: 'Android · arm64-v8a', sub: 'Recomendado: celulares nuevos' };
    if (/armeabi/i.test(name)) return { rank: 2, os: 'android', title: 'Android · armeabi-v7a', sub: 'Celulares más viejos (32 bits)' };
    if (/x86_64/i.test(name)) return { rank: 3, os: 'android', title: 'Android · x86_64', sub: 'Emuladores y Chromebooks' };
    return { rank: 9, os: '', title: name, sub: '' };
  }
  const mb = (n) => (n / 1048576).toFixed(0) + ' MB';

  function downloads(rel) {
    if (!rel || !rel.assets || !rel.assets.length) return '';
    const items = rel.assets.map((a) => ({ a, d: describe(a.name) })).sort((x, y) => x.d.rank - y.d.rank);
    const rec = items.find((i) => (isAndroid && i.d.os === 'android') || (!isAndroid && isWindows && i.d.os === 'windows')) || items[0];
    return '<div class="dls">' + items.map((i) =>
      `<a class="dl${i === rec ? ' rec' : ''}" href="${esc(i.a.browser_download_url)}"><b>${esc(i.d.title)}${i === rec ? ' · para vos' : ''}</b><span>${esc(i.d.sub)} · ${mb(i.a.size)}</span></a>`).join('') + '</div>';
  }

  function render(data, releases) {
    const byTag = {};
    (releases || []).forEach((r) => (byTag[r.tag_name] = r));
    const repo = data.repo;
    document.getElementById('vlist').innerHTML = data.versions.map((v) => {
      const rel = byTag[v.tag];
      const has = rel && rel.assets && rel.assets.length;
      const badge = v.upcoming ? '<span class="badge soon">Próxima</span>' : (v.latest ? '<span class="badge">Última</span>' : '');
      const status = has || v.upcoming ? '' : '<span class="badge off">Solo código</span>';
      let dl;
      if (v.upcoming) dl = '<div class="dls"><a class="dl none"><b>Todavía no disponible</b><span>Se publica cuando termine de probarse</span></a></div>';
      else if (has) dl = downloads(rel);
      else if (v.latest) dl = `<div class="dls"><a class="dl none"><b>Instaladores en camino</b><span>Se publican al subir la etiqueta ${esc(v.tag)}</span></a></div>`;
      else dl = `<div class="dls"><a class="dl" href="https://github.com/${repo}/tree/${esc(v.tag)}"><b>Ver el código de esta versión</b><span>Compilala con Flutter 3.47</span></a></div>`;
      return `<details class="ver${v.latest ? ' latest' : ''}"${v.latest ? ' open' : ''}>
        <summary><b>${esc(v.version)}</b>${badge}${status}<span>${esc(v.date)}</span></summary>
        <div class="vbody">
          <h4>${esc(v.title)}</h4>
          <ul>${v.highlights.map((h) => `<li>${esc(h)}</li>`).join('')}</ul>
          ${dl}
          <p class="muted small" style="margin-top:14px">${esc(v.notes)}${rel ? ` · <a href="${esc(rel.html_url)}">Ver en GitHub</a>` : ''}</p>
        </div></details>`;
    }).join('');
    // Botón principal
    const latest = (releases || []).find((r) => r.assets && r.assets.length);
    if (latest) {
      const items = latest.assets.map((a) => ({ a, d: describe(a.name) })).sort((x, y) => x.d.rank - y.d.rank);
      const pick = items.find((i) => (isAndroid && i.d.os === 'android') || (!isAndroid && isWindows && i.d.os === 'windows'));
      if (pick) {
        const b = document.getElementById('mainDl');
        b.href = pick.a.browser_download_url;
        b.textContent = 'Descargar para ' + (pick.d.os === 'android' ? 'Android' : 'Windows');
      }
    }
  }

  async function init() {
    const status = document.getElementById('apiStatus');
    const data = await fetch('versions.json').then((r) => r.json());
    document.getElementById('repoLink').href = 'https://github.com/' + data.repo;
    render(data, []);
    try {
      const res = await fetch(`https://api.github.com/repos/${data.repo}/releases?per_page=30`);
      if (!res.ok) throw new Error(res.status);
      const rels = await res.json();
      render(data, rels);
      status.textContent = rels.some((r) => r.assets && r.assets.length)
        ? 'Los archivos vienen directo de GitHub.'
        : 'Todavía no hay instaladores publicados. Volvé pronto.';
    } catch (e) {
      status.innerHTML = 'No pude consultar GitHub. Mirá <a href="https://github.com/' + data.repo + '/releases">todas las versiones</a>.';
    }
  }
  init();
})();

// Recorrido: arrastrar con el mouse en la compu (en el celular ya se desliza)
(function () {
  const s = document.getElementById('strip');
  if (!s) return;
  let down = false, x0 = 0, l0 = 0, moved = false;
  s.addEventListener('mousedown', (e) => { down = true; moved = false; x0 = e.pageX; l0 = s.scrollLeft; });
  window.addEventListener('mouseup', () => { down = false; s.classList.remove('drag'); });
  window.addEventListener('mousemove', (e) => {
    if (!down) return;
    const dx = e.pageX - x0;
    if (Math.abs(dx) > 4) { moved = true; s.classList.add('drag'); }
    s.scrollLeft = l0 - dx;
  });
})();

// Barra: más sólida al bajar y resalta la sección actual
(function () {
  const nav = document.querySelector('.nav');
  const links = [...document.querySelectorAll('.nav nav a[href^="#"]:not(.btn)')];
  const secs = links.map((a) => document.querySelector(a.getAttribute('href'))).filter(Boolean);
  function onScroll() {
    nav.classList.toggle('scrolled', scrollY > 60);
    const y = scrollY + innerHeight * 0.3;
    let cur = null;
    secs.forEach((s) => { if (s.offsetTop <= y) cur = s.id; });
    links.forEach((a) => a.classList.toggle('act', a.getAttribute('href') === '#' + cur));
  }
  addEventListener('scroll', onScroll, { passive: true });
  onScroll();
})();
