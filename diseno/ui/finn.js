// Finn reutilizable: finn('happy'|'celebrate'|'think'|'worry'|'sleep'|'rich', tamañoPx)
function finn(pose, size, opts) {
  opts = opts || {};
  const G = '#1F8F5F', D = '#24313A';
  const arm = (x, r) => `<ellipse cx="${x}" cy="14" rx="20" ry="14" fill="${G}" transform="rotate(${r} ${x} 14)"/>`;
  const armUp = (x, r) => `<ellipse cx="${x}" cy="-50" rx="14" ry="22" fill="${G}" transform="rotate(${r} ${x} -50)"/>`;
  const mouth = 'M-20 22 Q0 44 20 22';
  let arms = arm(-104, -25) + arm(104, 25), face = '', extra = '';
  const eyes = `<circle cx="-32" cy="-6" r="13" fill="${D}"/><circle cx="32" cy="-6" r="13" fill="${D}"/><circle cx="-28" cy="-11" r="5" fill="#fff"/><circle cx="36" cy="-11" r="5" fill="#fff"/><circle cx="-37" cy="0" r="2.5" fill="#fff"/><circle cx="27" cy="0" r="2.5" fill="#fff"/>`;
  const line = (d, w) => `<path d="${d}" fill="none" stroke="${D}" stroke-width="${w || 5}" stroke-linecap="round"/>`;
  let sprout = true;
  if (pose === 'happy') face = eyes + line(mouth);
  if (pose === 'celebrate') {
    arms = armUp(-100, -30) + armUp(100, 30);
    face = line('M-45 -4 Q-32 -24 -19 -4', 6) + line('M19 -4 Q32 -24 45 -4', 6) + `<path d="M-26 16 Q0 62 26 16 Z" fill="${D}"/><path d="M-14 34 Q0 46 14 34 Q0 28 -14 34 Z" fill="#FF8FA3"/>`;
  }
  if (pose === 'think') {
    arms = arm(-104, -25);
    face = `<circle cx="-30" cy="-10" r="13" fill="${D}"/><circle cx="34" cy="-10" r="13" fill="${D}"/><circle cx="-26" cy="-16" r="5" fill="#fff"/><circle cx="38" cy="-16" r="5" fill="#fff"/>` + line('M-48 -34 Q-32 -42 -16 -34', 4) + line('M16 -38 Q32 -48 48 -38', 4) + line('M-10 30 Q4 26 16 32') + `<ellipse cx="52" cy="62" rx="15" ry="12" fill="#2FB67C" stroke="#14704A" stroke-width="2.5"/>`;
  }
  if (pose === 'worry') {
    face = eyes + line('M-50 -24 L-18 -38', 5) + line('M50 -24 L18 -38', 5) + line('M-22 36 Q-11 26 0 36 Q11 46 22 36') + `<path d="M78 -50 Q92 -26 78 -16 Q64 -26 78 -50 Z" fill="#7CC4FF" stroke="#4DA3FF" stroke-width="2"/>`;
  }
  if (pose === 'sleep') {
    face = line('M-46 -4 Q-32 8 -18 -4', 6) + line('M18 -4 Q32 8 46 -4', 6) + `<ellipse cx="0" cy="34" rx="8" ry="6" fill="${D}"/><text x="84" y="-70" font-family="Nunito,Arial" font-size="40" font-weight="800" fill="#4DA3FF">Z</text><text x="112" y="-104" font-family="Nunito,Arial" font-size="30" font-weight="800" fill="#4DA3FF">z</text>`;
  }
  if (pose === 'rich') {
    sprout = false;
    face = eyes + line(mouth) + `<circle cx="32" cy="-6" r="24" fill="#fff" fill-opacity=".25" stroke="#E8A317" stroke-width="4"/><path d="M44 14 Q60 40 52 64" fill="none" stroke="#E8A317" stroke-width="3"/>`;
    extra = `<rect x="-52" y="-112" width="104" height="14" rx="6" fill="${D}"/><rect x="-34" y="-168" width="68" height="62" rx="8" fill="${D}"/><rect x="-34" y="-124" width="68" height="12" fill="#E8A317"/>`;
  }
  const cheeks = `<ellipse cx="-58" cy="22" rx="14" ry="9" fill="#FF8FA3" opacity=".7"/><ellipse cx="58" cy="22" rx="14" ry="9" fill="#FF8FA3" opacity=".7"/>`;
  const sp = sprout ? `<path d="M0 -98 Q-4 -112 0 -120" stroke="${G}" stroke-width="5" fill="none" stroke-linecap="round"/><circle cx="0" cy="-132" r="17" fill="url(#fc)" stroke="#C98700" stroke-width="3"/><text x="0" y="-126" font-family="Nunito,Arial" font-size="${opts.sym && opts.sym.length > 1 ? 14 : 18}" font-weight="800" fill="#C98700" text-anchor="middle">${opts.sym || '₲'}</text>` : '';
  const vb = pose === 'rich' ? '-135 -185 270 310' : (pose === 'celebrate' ? '-135 -158 270 288' : '-135 -158 270 288');
  const w = size, h = Math.round(size * (pose === 'rich' ? 310 : 288) / 270);
  return `<svg width="${w}" height="${h}" viewBox="${vb}" style="flex:none;overflow:visible"><defs><radialGradient id="fb" cx="38%" cy="30%" r="80%"><stop offset="0" stop-color="#7BE0B2"/><stop offset=".55" stop-color="#2FB67C"/><stop offset="1" stop-color="#1F8F5F"/></radialGradient><radialGradient id="fc" cx="35%" cy="30%" r="80%"><stop offset="0" stop-color="#FFE98A"/><stop offset="1" stop-color="#E8A317"/></radialGradient></defs>
  <ellipse cx="-42" cy="100" rx="26" ry="17" fill="${G}"/><ellipse cx="42" cy="100" rx="26" ry="17" fill="${G}"/>${arms}
  <circle r="100" fill="url(#fb)"/><path d="M-70 -62 A100 100 0 0 1 20 -98" fill="none" stroke="#fff" stroke-opacity=".45" stroke-width="10" stroke-linecap="round"/><path d="M-86 52 A100 100 0 0 0 86 52" fill="none" stroke="${G}" stroke-opacity=".55" stroke-width="3" stroke-dasharray="7 7" stroke-linecap="round"/>
  ${sp}${cheeks}${face}${extra}</svg>`;
}
