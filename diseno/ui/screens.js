// Todas las pantallas de AltFin. Se muestran con s.html?n=<clave>
const I = {
  home: '<svg viewBox="0 0 24 24"><path d="M3 11l9-8 9 8v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/></svg>',
  list: '<svg viewBox="0 0 24 24"><path d="M8 6h12M8 12h12M8 18h12"/><circle cx="4" cy="6" r="1"/><circle cx="4" cy="12" r="1"/><circle cx="4" cy="18" r="1"/></svg>',
  target: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1"/></svg>',
  face: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><circle cx="9" cy="10" r="1"/><circle cx="15" cy="10" r="1"/><path d="M8.5 14.5q3.5 3 7 0"/></svg>',
  chart: '<svg viewBox="0 0 24 24"><path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/></svg>',
  gear: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M5 5l2 2M17 17l2 2M19 5l-2 2M7 17l-2 2"/></svg>',
  bell: '<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M6 17V11a6 6 0 0 1 12 0v6l2 2H4z"/><path d="M10 21h4"/></svg>',
  back: '<svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M15 5l-7 7 7 7"/></svg>',
};
const status = (t) => `<div class="status"><span>${t || '9:41'}</span><span class="ic">▂▄▆ 5G ▮</span></div>`;
const nav = (on) => {
  const it = (k, ic, l) => `<div class="it ${on === k ? 'on' : ''}">${I[ic]}<span>${l}</span></div>`;
  return `<div class="nav">${it('home', 'home', 'Inicio')}${it('mov', 'list', 'Movimientos')}<div class="fab">+</div>${it('metas', 'target', 'Metas')}${it('finn', 'face', 'Finn')}<div class="home-ind"></div></div>`;
};
const phone = (body, on, t) => `<div class="phone">${status(t)}<div class="scroll">${body}</div>${on === false ? '<div class="home-ind"></div>' : nav(on)}</div>`;
const topbar = (title, right) => `<div class="row sp" style="padding-top:2px"><div style="color:var(--ink)">${I.back}</div><h2>${title}</h2><div style="min-width:26px;text-align:right;font-weight:800;color:var(--green-d)">${right || ''}</div></div>`;
const item = (ic, cls, name, sub, amt, pos) => `<div class="li"><div class="ico ${cls}">${ic}</div><div><b>${name}</b><span class="small">${sub}</span></div><div class="amt num ${pos ? 'pos' : ''}">${amt}</div></div>`;
const cat = (ic, cls, name, spent, total, p, barcls, pill) => `<div style="padding:9px 0"><div class="row"><div class="ico ${cls}" style="width:38px;height:38px;font-size:24px">${ic}</div><div class="grow"><div class="row sp"><b style="font-size:15px">${name}</b><span class="num" style="font-weight:800;font-size:14px">${spent} <span class="small">/ ${total}</span></span></div><div class="bar t ${barcls}" style="margin-top:6px"><i style="width:${p}%"></i></div></div></div></div>`;

const S = {};

// 1. Bienvenida
S.bienvenida = () => phone(`
  <div style="height:8px"></div>
  <div class="row" style="justify-content:center;gap:6px"><div class="step" style="max-width:40px"><i style="width:100%"></i></div><div class="step" style="max-width:40px"></div><div class="step" style="max-width:40px"></div><div class="step" style="max-width:40px"></div><div class="step" style="max-width:40px"></div></div>
  <div style="flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;gap:14px">
    <div style="position:relative;margin-top:30px"><div style="position:absolute;inset:auto -30px -10px -30px;height:70px;border-radius:50%;background:var(--green-s);z-index:0"></div><div style="position:relative">${finn('celebrate', 230)}</div></div>
    <h1 style="margin-top:26px">¡Hola! Soy <span style="color:var(--green-d)">Finn</span></h1>
    <p class="sub" style="font-size:17px;line-height:1.4;max-width:290px">Te ayudo a ahorrar la mitad de tu sueldo y a ver crecer tu plata, un día a la vez.</p>
  </div>
  <div class="btn">EMPEZAR</div>
  <div class="btn ghost" style="height:50px;box-shadow:none;margin-bottom:14px">Ya tengo una copia de seguridad</div>`, false);

// 2. Sueldo
S.sueldo = () => phone(`
  <div class="row" style="gap:12px"><div style="color:var(--muted)">${I.back}</div><div class="step"><i style="width:40%"></i></div></div>
  <div class="row" style="align-items:flex-start;gap:6px;margin-top:6px">${finn('happy', 92)}<div class="bubble" style="margin-top:20px">¡Empecemos por lo básico! ¿Cuánto cobrás al mes?</div></div>
  <div><div class="small" style="margin-bottom:8px">TU SUELDO NETO (LO QUE TE LLEGA)</div>
  <div class="card" style="border:3px solid var(--green);padding:18px"><div class="row sp"><div class="num" style="font-size:38px;font-weight:800">₲ 5.000.000</div></div></div></div>
  <div class="row"><span class="chip on">₲ Guaraníes</span><span class="chip">US$ Dólares</span></div>
  <div><div class="small" style="margin-bottom:8px">¿CADA CUÁNTO COBRÁS?</div><div class="row" style="flex-wrap:wrap"><span class="chip on">Mensual</span><span class="chip">Quincenal</span><span class="chip">Semanal</span><span class="chip">Variable</span></div></div>
  <div><div class="small" style="margin-bottom:8px">DÍA DE COBRO</div><div class="card row sp" style="padding:14px 16px"><b>Cada día</b><b class="num" style="color:var(--green-d)">1 del mes ▾</b></div></div>
  <div style="flex:1"></div><div class="btn" style="margin-bottom:16px">CONTINUAR</div>`, false);

// 3. Perfil de ahorro
S.perfil = () => phone(`
  <div class="row" style="gap:12px"><div style="color:var(--muted)">${I.back}</div><div class="step"><i style="width:60%"></i></div></div>
  <h1 style="margin-top:4px">Elegí tu meta de ahorro</h1><p class="sub" style="margin-top:-8px">Con un sueldo de ₲ 5.000.000. Podés cambiarlo cuando quieras.</p>
  <div class="card" style="border:3px solid var(--green);position:relative;padding:14px 16px"><span class="pill g" style="position:absolute;right:14px;top:-12px;background:var(--green);color:#fff">${ic('rocket')} RECOMENDADO PARA ENRIQUECERTE</span>
    <div class="row sp"><h2>Modo Cohete</h2><b class="num" style="font-size:22px;color:var(--green-d)">50%</b></div>
    <div class="row" style="height:14px;border-radius:99px;overflow:hidden;margin:10px 0 8px;gap:2px"><i style="flex:40;background:var(--blue);height:100%"></i><i style="flex:10;background:var(--orange);height:100%"></i><i style="flex:50;background:var(--green);height:100%"></i></div>
    <div class="row sp small"><span style="color:#2477D1">Necesidades 40%</span><span style="color:#B3640B">Gustos 10%</span><span style="color:var(--green-d)">Ahorro 50%</span></div>
    <div class="row sp" style="margin-top:10px"><span class="sub">Ahorrás por mes</span><b class="num" style="font-size:18px">₲ 2.500.000</b></div></div>
  <div class="card" style="padding:14px 16px"><div class="row sp"><h2>Equilibrado</h2><b class="num" style="font-size:22px;color:var(--muted)">30%</b></div>
    <div class="row" style="height:14px;border-radius:99px;overflow:hidden;margin:10px 0 8px;gap:2px"><i style="flex:50;background:var(--blue);height:100%"></i><i style="flex:20;background:var(--orange);height:100%"></i><i style="flex:30;background:var(--green);height:100%"></i></div>
    <div class="row sp"><span class="sub">Ahorrás por mes</span><b class="num">₲ 1.500.000</b></div></div>
  <div class="card" style="padding:14px 16px"><div class="row sp"><h2>Personalizado</h2><span style="font-size:20px">${ic('sliders')}</span></div><p class="sub" style="margin-top:4px">Movés los deslizadores a tu gusto.</p></div>
  <div style="flex:1"></div><div class="btn" style="margin-bottom:16px">ELEGIR MODO COHETE</div>`, false);

// 4. Inicio
const inicio = (dark) => phone(`
  <div class="row sp"><div><div class="sub">Buen día, Beni</div><h2 style="font-size:22px">Octubre 2026</h2></div><div class="row"><span class="pill o" style="font-size:14px">${ic('flame')} 12</span><div class="card" style="padding:9px;border-radius:14px;color:var(--ink)">${I.bell}</div></div></div>
  <div class="card mint row" style="padding:12px 14px 12px 8px;gap:8px">${finn('happy', 92)}<div><div style="font-size:12px;font-weight:800;opacity:.75">PODÉS GASTAR HOY</div><div class="num" style="font-size:34px;font-weight:800;line-height:1.1">₲ 35.800</div><div style="font-size:13px;font-weight:700;opacity:.85;margin-top:2px">¡Vas bien! Te quedan ₲ 680.000 para 19 días.</div></div></div>
  <div class="card" style="padding:14px 16px"><div class="row sp" style="margin-bottom:10px"><h2 style="font-size:16px">Tu plan del mes</h2><span class="small">día 12 de 31</span></div>
    <div style="display:flex;flex-direction:column;gap:10px">
    <div><div class="row sp"><b style="font-size:14px">${ic('home')} Necesidades</b><span class="num small" style="color:var(--ink)">₲ 1.150.000 / 2.000.000</span></div><div class="bar b t" style="margin-top:5px"><i style="width:57%"></i></div></div>
    <div><div class="row sp"><b style="font-size:14px">${ic('clapper')} Gustos</b><span class="num small" style="color:var(--ink)">₲ 310.000 / 500.000</span></div><div class="bar o t" style="margin-top:5px"><i style="width:62%"></i></div></div>
    <div><div class="row sp"><b style="font-size:14px">${ic('sprout')} Ahorro e inversión</b><span class="num small" style="color:var(--ink)">₲ 1.250.000 / 2.500.000</span></div><div class="bar t" style="margin-top:5px"><i style="width:50%"></i></div></div></div></div>
  <div class="card" style="padding:6px 16px"><div class="row sp" style="padding-top:8px"><h2 style="font-size:16px">Últimos movimientos</h2><span class="small" style="color:var(--green-d)">Ver todo</span></div>
    ${item(ic('food'), 'i-o', 'Tereré y chipa', 'Hoy · Comida', '−₲ 18.000')}${item(ic('cart'), 'i-g', 'Supermercado', 'Ayer · Súper', '−₲ 185.000')}</div>
  <div class="card" style="padding:12px 16px"><div class="row sp"><h2 style="font-size:16px">Tu racha ${ic('flame')}</h2><span class="small">12 días seguidos</span></div><div class="wk" style="margin-top:6px"><div class="d">L<b>✓</b></div><div class="d">M<b>✓</b></div><div class="d">M<b>✓</b></div><div class="d">J<b>✓</b></div><div class="d">V<b>✓</b></div><div class="d">S<b>✓</b></div><div class="t">D<b></b></div></div></div>`, 'home');
S.inicio = () => inicio();
S.inicio_oscuro = () => inicio(true);

// 5. Añadir gasto
S.gasto = () => phone(`
  <div class="row sp"><div style="color:var(--muted)">${I.back}</div><div class="row" style="background:var(--line);border-radius:99px;padding:4px"><span class="chip on" style="border:0;padding:7px 18px">Gasto</span><span class="chip" style="border:0;background:transparent;padding:7px 18px">Ingreso</span></div><div style="width:26px"></div></div>
  <div style="text-align:center;margin-top:2px"><div class="small">MONTO</div><div class="num" style="font-size:52px;font-weight:800;line-height:1.1">₲ 35.000</div><span class="chip" style="font-size:12px;padding:4px 12px">₲ Guaraníes ⇄</span></div>
  <div><div class="small" style="margin-bottom:8px">CATEGORÍA</div>
   <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;text-align:center;font-size:12px;font-weight:800">
    <div><div class="ico i-o" style="width:100%;height:56px;border:3px solid var(--green);font-size:26px">${ic('food')}</div>Comida</div>
    <div><div class="ico i-b" style="width:100%;height:60px;font-size:38px">${ic('bus')}</div>Transporte</div>
    <div><div class="ico i-g" style="width:100%;height:60px;font-size:38px">${ic('cart')}</div>Súper</div>
    <div><div class="ico i-p" style="width:100%;height:60px;font-size:38px">${ic('clapper')}</div>Ocio</div></div></div>
  <div class="row"><div class="card row grow" style="padding:12px 14px">${ic('note')} <span class="sub">Nota (opcional)</span></div><span class="chip on" style="padding:14px">${ic('calendar')} Hoy</span></div>
  <div class="keys">${['1','2','3','4','5','6','7','8','9','000','0','⌫'].map(k => `<div>${k}</div>`).join('')}</div>
  <div class="btn" style="margin-bottom:14px">GUARDAR GASTO · +10 XP</div>`, false);

// 6. Movimientos
S.movimientos = () => phone(`
  <div class="row sp"><h1>Movimientos</h1><div class="card" style="padding:9px 12px;border-radius:14px;font-size:18px">${ic('search')}</div></div>
  <div class="row" style="overflow:hidden"><span class="chip on">Todos</span><span class="chip">Gastos</span><span class="chip">Ingresos</span><span class="chip">Octubre ▾</span></div>
  <div class="row sp"><span class="small">HOY · JUE 1 OCT</span><span class="num small">−₲ 18.000</span></div>
  <div class="card" style="padding:2px 16px">${item(ic('food'), 'i-o', 'Tereré y chipa', 'Comida · Efectivo', '−₲ 18.000')}</div>
  <div class="row sp"><span class="small">AYER</span><span class="num small">−₲ 210.000</span></div>
  <div class="card" style="padding:2px 16px">${item(ic('cart'), 'i-g', 'Supermercado Stock', 'Súper · Tarjeta', '−₲ 185.000')}${item(ic('bus'), 'i-b', 'Bolt al trabajo', 'Transporte', '−₲ 25.000')}</div>
  <div class="row sp"><span class="small">MIÉ 30 SEP</span><span class="num small">+₲ 5.000.000</span></div>
  <div class="card" style="padding:2px 16px">${item(ic('briefcase'), 'i-g', 'Sueldo', 'Ingreso · Banco', '+₲ 5.000.000', true)}${item(ic('bulb'), 'i-r', 'ANDE (luz)', 'Servicios · Débito', '−₲ 240.000')}${item(ic('tv'), 'i-p', 'Netflix', 'Suscripción', '−₲ 45.000')}</div>`, 'mov');

// 7. Presupuesto
S.presupuesto = () => phone(`
  <div class="row sp"><h1>Presupuesto</h1><span class="pill g">Modo Cohete</span></div>
  <div class="row" style="gap:10px">
    <div class="card grow" style="padding:12px;text-align:center"><div class="ring" style="--p:57;--c:var(--blue);--s:78px"><div style="font-size:15px">57%</div></div><div style="font-weight:800;margin-top:6px;font-size:13px">Necesidades</div><div class="small num">₲ 2.000.000</div></div>
    <div class="card grow" style="padding:12px;text-align:center"><div class="ring" style="--p:62;--c:var(--orange);--s:78px"><div style="font-size:15px">62%</div></div><div style="font-weight:800;margin-top:6px;font-size:13px">Gustos</div><div class="small num">₲ 500.000</div></div>
    <div class="card grow" style="padding:12px;text-align:center"><div class="ring" style="--p:50;--s:78px"><div style="font-size:15px">50%</div></div><div style="font-weight:800;margin-top:6px;font-size:13px">Ahorro</div><div class="small num">₲ 2.500.000</div></div></div>
  <div class="card" style="padding:6px 16px"><div class="row sp" style="padding:8px 0 2px"><h2 style="font-size:16px">Por categoría</h2><span class="small" style="color:var(--green-d)">+ Nueva</span></div>
    ${cat(ic('home'), 'i-b', 'Alquiler', '₲ 1.000.000', '1.000.000', 100, 'b')}
    ${cat(ic('cart'), 'i-g', 'Súper', '₲ 420.000', '600.000', 70, '')}
    ${cat(ic('food'), 'i-o', 'Comida afuera', '₲ 235.000', '280.000', 84, 'o')}
    ${cat(ic('bus'), 'i-b', 'Transporte', '₲ 190.000', '250.000', 76, 'o')}
    ${cat(ic('clapper'), 'i-p', 'Ocio', '₲ 75.000', '220.000', 34, '')}
    ${cat(ic('bulb'), 'i-r', 'Servicios', '₲ 240.000', '300.000', 80, 'o')}</div>
  <div class="bubble row" style="gap:10px;align-self:stretch;padding:10px 14px">${finn('worry', 46)}<span style="font-size:13px">Comida afuera va al 84 %. ¿Probamos cocinar en casa unos días?</span></div>`, 'home');

// 8. Metas
S.metas = () => phone(`
  <div class="row sp"><h1>Mis metas</h1><span class="pill g">+ Nueva</span></div>
  <div class="card mint" style="padding:16px"><div class="row sp"><div><div style="font-size:12px;font-weight:800;opacity:.75">FONDO DE EMERGENCIA</div><div class="num" style="font-size:28px;font-weight:800">₲ 6.900.000</div><div style="font-size:13px;font-weight:700;opacity:.85">cubre 1,4 meses de tus gastos</div></div><div class="ring" style="--p:46;--s:84px"><div style="font-size:16px;color:var(--ink)">46%</div></div></div><div style="margin-top:10px;font-size:12px;font-weight:800;opacity:.8">Meta: 6 meses = ₲ 15.000.000 · listo en ~3,5 meses</div></div>
  <div class="card row" style="gap:14px"><div class="ico i-b" style="width:54px;height:54px;font-size:28px">${ic('plane')}</div><div class="grow"><div class="row sp"><b>Viaje a Brasil</b><span class="pill b">dic 2026</span></div><div class="bar b" style="margin:8px 0 5px"><i style="width:68%"></i></div><div class="row sp small"><span class="num">₲ 3.400.000 / 5.000.000</span><span>68%</span></div></div></div>
  <div class="card row" style="gap:14px"><div class="ico i-o" style="width:54px;height:54px;font-size:28px">${ic('laptop')}</div><div class="grow"><div class="row sp"><b>Laptop nueva</b><span class="pill o">mar 2027</span></div><div class="bar o" style="margin:8px 0 5px"><i style="width:30%"></i></div><div class="row sp small"><span class="num">₲ 1.200.000 / 4.000.000</span><span>30%</span></div></div></div>
  <div class="card row" style="gap:14px"><div class="ico i-g" style="width:54px;height:54px;font-size:28px">${ic('villa')}</div><div class="grow"><div class="row sp"><b>Entrada para terreno</b><span class="pill g">2029</span></div><div class="bar" style="margin:8px 0 5px"><i style="width:9%"></i></div><div class="row sp small"><span class="num">₲ 4.500.000 / 50.000.000</span><span>9%</span></div></div></div>
  <div class="bubble row" style="gap:10px;align-self:stretch;padding:10px 14px">${finn('celebrate', 50)}<span style="font-size:13px">¡Tu viaje al 68 %! Si seguís así, lo cumplís en 6 semanas.</span></div>`, 'metas');

// 9. Inversión y simulador
S.inversion = () => phone(`
  <div class="row sp"><h1>Crecer</h1><span class="pill g">Simulador</span></div>
  <div class="card" style="padding:16px"><div class="small">EN 10 AÑOS PODRÍAS TENER</div><div class="num" style="font-size:36px;font-weight:800;color:var(--green-d)">₲ 182.900.000</div><div class="row small" style="margin-top:2px"><span>Aportás ₲ 120.000.000</span><span class="pill g">+₲ 62.900.000 de interés</span></div>
   <svg viewBox="0 0 320 130" style="width:100%;margin-top:10px"><defs><linearGradient id="g1" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#2FB67C" stop-opacity=".35"/><stop offset="1" stop-color="#2FB67C" stop-opacity="0"/></linearGradient></defs>
   <path d="M0 120 L320 120" stroke="var(--line)" stroke-width="2"/><path d="M0 120 L320 62" stroke="#BFC8CC" stroke-width="3" stroke-dasharray="6 6" fill="none"/>
   <path d="M0 120 C80 112 160 96 230 64 S300 14 320 6 L320 120 L0 120 Z" fill="url(#g1)"/><path d="M0 120 C80 112 160 96 230 64 S300 14 320 6" stroke="#2FB67C" stroke-width="4" fill="none" stroke-linecap="round"/><circle cx="320" cy="6" r="6" fill="#2FB67C"/></svg>
   <div class="row sp small"><span>Hoy</span><span>5 años</span><span>10 años</span></div></div>
  <div class="card" style="display:flex;flex-direction:column;gap:14px">
   <div><div class="row sp"><b>Aporte mensual</b><b class="num" style="color:var(--green-d)">₲ 1.000.000</b></div><div class="bar" style="margin-top:8px;height:8px;position:relative"><i style="width:45%"></i></div></div>
   <div><div class="row sp"><b>Rendimiento anual</b><b class="num" style="color:var(--green-d)">8 %</b></div><div class="bar" style="margin-top:8px;height:8px"><i style="width:38%"></i></div></div>
   <div><div class="row sp"><b>Años</b><b class="num" style="color:var(--green-d)">10</b></div><div class="bar" style="margin-top:8px;height:8px"><i style="width:33%"></i></div></div></div>
  <div class="card mint row" style="gap:10px;padding:12px 14px">${finn('rich', 60)}<div style="font-size:13px;font-weight:700">Con ₲ 1.000.000 más al mes llegás a la libertad financiera <b>8 años antes</b>.</div></div>
  <p class="small" style="text-align:center">Simulación orientativa. No es asesoría financiera.</p>`, 'metas');

// 10. Informes
S.informes = () => phone(`
  <div class="row sp"><h1>Informe</h1><div class="row"><span class="chip">Mes</span><span class="chip on">Año</span></div></div>
  <div class="card" style="padding:16px"><div class="row sp"><div><div class="small">TASA DE AHORRO</div><div class="num" style="font-size:34px;font-weight:800;color:var(--green-d)">47 %</div></div><span class="pill g">▲ +6 pts vs sept.</span></div>
   <svg viewBox="0 0 320 120" style="width:100%;margin-top:8px"><g fill="#4DA3FF">${[0,1,2,3,4,5].map((i) => `<rect x="${10 + i * 52}" y="${[40,48,34,52,30,36][i]}" width="16" height="${120 - [40,48,34,52,30,36][i] - 18}" rx="5"/>`).join('')}</g><g fill="#2FB67C">${[0,1,2,3,4,5].map((i) => `<rect x="${28 + i * 52}" y="${[70,64,72,60,66,52][i]}" width="16" height="${120 - [70,64,72,60,66,52][i] - 18}" rx="5"/>`).join('')}</g>
   ${['May','Jun','Jul','Ago','Sep','Oct'].map((m, i) => `<text x="${27 + i * 52}" y="116" font-size="11" font-weight="800" fill="#7A8790" text-anchor="middle" font-family="Nunito">${m}</text>`).join('')}</svg>
   <div class="row small" style="gap:14px"><span>${dot('#4DA3FF')} Ingresos</span><span>${dot('#2FB67C')} Ahorro</span></div></div>
  <div class="card row" style="gap:16px;padding:16px"><div class="ring" style="--p:100;--s:110px;background:conic-gradient(var(--blue) 0 38%,var(--orange) 0 56%,var(--green) 0 80%,#B58AE8 0 100%)"><div style="font-size:12px;color:var(--ink)"><span class="num" style="font-size:12px">₲1,46M</span><br><span class="small">gastado</span></div></div>
   <div class="grow" style="display:flex;flex-direction:column;gap:7px;font-size:13px;font-weight:800">
   <div class="row sp"><span>${dot('#4DA3FF')} Hogar</span><span class="num">38%</span></div><div class="row sp"><span>${dot('#FF9F43')} Comida</span><span class="num">18%</span></div><div class="row sp"><span>${dot('#2FB67C')} Súper</span><span class="num">24%</span></div><div class="row sp"><span>${dot('#B58AE8')} Otros</span><span class="num">20%</span></div></div></div>
  <div class="card mint row" style="gap:10px;padding:12px 14px">${finn('happy', 56)}<div style="font-size:13px;font-weight:700"><b>Finn te cuenta:</b> gastaste 12 % menos en comida afuera que en septiembre. ¡Sigue así!</div></div>`, 'finn');

// 11. Finn y logros
S.finn = () => phone(`
  <div class="row sp"><h1>Finn</h1><span class="pill o">${ic('coin')} 340 monedas</span></div>
  <div class="card mint" style="text-align:center;padding:10px 16px 16px"><div style="display:flex;justify-content:center;margin-top:6px">${finn('happy', 150)}</div><h2 style="margin-top:4px">Finn Estudiante · Nivel 12</h2>
   <div class="bar" style="margin:8px 0 4px;background:rgba(255,255,255,.55)"><i style="width:72%"></i></div><div class="small" style="color:inherit;opacity:.8">720 / 1.000 XP para el nivel 13</div></div>
  <div class="row" style="gap:10px"><div class="card grow" style="text-align:center;padding:12px"><div style="font-size:26px">${ic('flame')}</div><div class="num" style="font-size:22px;font-weight:800">12</div><div class="small">días de racha</div></div><div class="card grow" style="text-align:center;padding:12px"><div style="font-size:26px">${ic('medal')}</div><div class="num" style="font-size:22px;font-weight:800">7</div><div class="small">insignias</div></div><div class="card grow" style="text-align:center;padding:12px"><div style="font-size:26px">${ic('snow')}</div><div class="num" style="font-size:22px;font-weight:800">1</div><div class="small">congelador</div></div></div>
  <div class="card" style="padding:14px 16px"><div class="row sp" style="margin-bottom:10px"><h2 style="font-size:16px">Insignias</h2><span class="small" style="color:var(--green-d)">Ver todas</span></div>
   <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;text-align:center;font-size:11px;font-weight:800">
   <div><div class="ico i-g" style="width:100%;height:58px;font-size:36px">${ic('sprout')}</div>Primer ahorro</div><div><div class="ico i-o" style="width:100%;height:58px;font-size:36px">${ic('flame')}</div>7 días</div><div><div class="ico i-b" style="width:100%;height:58px;font-size:36px">${ic('lifebuoy')}</div>1 mes de fondo</div><div><div class="ico" style="width:100%;height:58px;font-size:36px;background:var(--line);filter:grayscale(1);opacity:.6">${ic('crown')}</div>Deuda cero</div></div></div>
  <div class="card row" style="gap:12px;padding:12px 14px"><div class="ico i-p" style="width:48px;height:48px;font-size:26px">${ic('backpack')}</div><div class="grow"><b>Mochila de estudiante</b><div class="small">Nuevo accesorio para Finn</div></div><span class="pill o">${ic('coin')} 120</span></div>`, 'finn');

// 12. Ajustes y notificaciones
S.ajustes = () => phone(`
  <div class="row sp"><h1>Ajustes</h1><div style="width:26px"></div></div>
  <div class="small" style="margin:2px 0 -6px">ASÍ TE RECUERDA FINN</div>
  <div class="card row" style="gap:12px;padding:12px 14px"><div style="width:46px;height:46px;border-radius:14px;background:var(--green-s);display:grid;place-items:center;overflow:hidden">${finn('happy', 40)}</div><div class="grow"><div class="row sp"><b style="font-size:14px">AltFin</b><span class="small">ahora</span></div><div style="font-size:14px;font-weight:700">¿Cómo te fue hoy? Anotá tus gastos en 5 segundos</div><div class="row" style="margin-top:8px;gap:8px"><span class="pill g">+ Gasto</span><span class="pill b">Hoy no gasté</span></div></div></div>
  <div class="card" style="padding:4px 16px">
   <div class="li"><div class="ico i-g">${ic('bell')}</div><div class="grow"><b>Recordatorio diario</b><span class="small">20:00 · solo si no anotaste hoy</span></div><div class="tog on"></div></div>
   <div class="li"><div class="ico i-r">${ic('chart')}</div><div class="grow"><b>Límite de presupuesto</b><span class="small">Al 80 % y al 100 %</span></div><div class="tog on"></div></div>
   <div class="li"><div class="ico i-g">${ic('moon')}</div><div class="grow"><b>Horas de silencio</b><span class="small">22:00 – 07:00</span></div><div class="tog on"></div></div></div>
  <div class="card" style="padding:4px 16px">
   <div class="li"><div class="ico i-b">${ic('lock')}</div><div class="grow"><b>Bloqueo con huella o PIN</b></div><div class="tog on"></div></div>
   <div class="li"><div class="ico i-g">${ic('exchange')}</div><div class="grow"><b>Monedas</b><span class="small">₲ Guaraní · US$ Dólar</span></div><span class="small">›</span></div>
   <div class="li"><div class="ico i-o">${ic('save')}</div><div class="grow"><b>Copia de seguridad</b><span class="small">Todo se guarda solo en tu dispositivo</span></div><span class="small">›</span></div></div>`, 'finn');

// 13. Escritorio
S.escritorio = () => `<div class="desk"><div class="titlebar"><span class="dots"><i style="background:#FF6B6B"></i><i style="background:#FFD23F"></i><i style="background:#2FB67C"></i></span>AltFin</div>
 <div style="display:flex;flex:1;overflow:hidden"><div class="side"><div class="row" style="padding:4px 10px 14px;gap:8px">${finn('happy', 42)}<b style="font-size:22px;font-weight:900">Alt<span style="color:var(--green-d)">Fin</span></b></div>
  <div class="it on">${I.home.replace('<svg', '<svg width="22" height="22" style="stroke:currentColor;fill:none;stroke-width:2.2"')} Inicio</div><div class="it">${I.list.replace('<svg', '<svg width="22" height="22" style="stroke:currentColor;fill:none;stroke-width:2.2"')} Movimientos</div><div class="it">${I.chart.replace('<svg', '<svg width="22" height="22" style="stroke:currentColor;fill:none;stroke-width:2.2"')} Presupuesto</div><div class="it">${I.target.replace('<svg', '<svg width="22" height="22" style="stroke:currentColor;fill:none;stroke-width:2.2"')} Metas</div><div class="it">${I.face.replace('<svg', '<svg width="22" height="22" style="stroke:currentColor;fill:none;stroke-width:2.2"')} Finn y logros</div><div class="it">${I.gear.replace('<svg', '<svg width="22" height="22" style="stroke:currentColor;fill:none;stroke-width:2.2"')} Ajustes</div>
  <div style="flex:1"></div><div class="btn" style="height:52px;font-size:14px;white-space:nowrap">+ ANOTAR GASTO</div><div class="small" style="text-align:center">Atajo: Ctrl + Alt + G</div></div>
 <div class="main"><div class="row sp"><div><div class="sub">Buen día, Beni</div><h1>Octubre 2026</h1></div><div class="row"><span class="pill o" style="font-size:15px">${ic('flame')} 12 días</span><span class="pill g" style="font-size:15px">Nivel 12</span></div></div>
  <div class="grid3"><div class="card mint row" style="gap:18px;padding:20px">${finn('happy', 130)}<div><div style="font-size:13px;font-weight:800;opacity:.75">PODÉS GASTAR HOY</div><div class="num" style="font-size:44px;font-weight:800;line-height:1.1;white-space:nowrap">₲ 35.800</div><div style="font-size:15px;font-weight:700;opacity:.85;margin-top:4px">¡Vas bien! Te quedan ₲ 680.000 para 19 días.</div></div></div>
   <div class="card"><div class="row sp"><h2>Ahorro del mes</h2><span class="pill g">50 %</span></div><div class="row" style="gap:18px;margin-top:12px"><div class="ring" style="--p:50;--s:110px"><div class="num" style="font-size:20px">50%</div></div><div><div class="num" style="font-size:24px;font-weight:800">₲ 1.250.000</div><div class="small">de ₲ 2.500.000</div><div class="small" style="margin-top:8px;color:var(--green-d)">Finn: ¡vas en camino!</div></div></div></div>
   <div class="card"><div class="row sp"><h2>Meta: Viaje a Brasil</h2><span class="pill b">dic 2026</span></div><div class="row" style="gap:14px;margin-top:12px"><div class="ico i-b" style="width:58px;height:58px;font-size:30px">${ic('plane')}</div><div class="grow"><div class="num" style="font-size:22px;font-weight:800">₲ 3.400.000</div><div class="bar b" style="margin:8px 0 4px"><i style="width:68%"></i></div><div class="small">68 % de ₲ 5.000.000</div></div></div></div></div>
  <div style="display:grid;grid-template-columns:1.2fr 1fr;gap:18px;flex:1;min-height:0"><div class="card"><div class="row sp"><h2>Plan del mes</h2><span class="small">día 12 de 31</span></div><div style="display:flex;flex-direction:column;gap:14px;margin-top:14px">
   <div><div class="row sp"><b>${ic('home')} Necesidades</b><span class="num small" style="color:var(--ink)">₲ 1.150.000 / 2.000.000</span></div><div class="bar b" style="margin-top:6px"><i style="width:57%"></i></div></div>
   <div><div class="row sp"><b>${ic('clapper')} Gustos</b><span class="num small" style="color:var(--ink)">₲ 310.000 / 500.000</span></div><div class="bar o" style="margin-top:6px"><i style="width:62%"></i></div></div>
   <div><div class="row sp"><b>${ic('sprout')} Ahorro e inversión</b><span class="num small" style="color:var(--ink)">₲ 1.250.000 / 2.500.000</span></div><div class="bar" style="margin-top:6px"><i style="width:50%"></i></div></div></div></div>
   <div class="card" style="padding:8px 18px"><div class="row sp" style="padding:8px 0"><h2>Últimos movimientos</h2><span class="small" style="color:var(--green-d)">Ver todo</span></div>${item(ic('food'), 'i-o', 'Tereré y chipa', 'Hoy · Comida', '−₲ 18.000')}${item(ic('cart'), 'i-g', 'Supermercado Stock', 'Ayer · Súper', '−₲ 185.000')}${item(ic('briefcase'), 'i-g', 'Sueldo', '30 sep · Ingreso', '+₲ 5.000.000', true)}${item(ic('bulb'), 'i-r', 'ANDE (luz)', '30 sep · Servicios', '−₲ 240.000')}</div></div></div></div></div>`;

// 14. Sistema de diseño
S.sistema = () => `<div style="width:1100px;background:#FFF9F0;border-radius:24px;padding:36px;display:grid;grid-template-columns:1fr 1fr;gap:30px;box-shadow:0 20px 50px rgba(40,30,10,.2)">
 <div><h1 style="font-size:34px">AltFin · Sistema de diseño</h1><p class="sub" style="margin:6px 0 20px">Cálido, redondeado y claro. Nunca culpa, siempre aliento.</p>
  <h2 style="margin-bottom:10px">Colores</h2><div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px;font-size:12px;font-weight:800">
  ${[['Verde menta','#2FB67C','#fff'],['Verde oscuro','#1F8F5F','#fff'],['Naranja','#FF9F43','#fff'],['Azul','#4DA3FF','#fff'],['Rojo suave','#F25F5C','#fff'],['Crema','#FFF4E0','#24313A'],['Tinta','#24313A','#fff'],['Moneda','#E8A317','#fff']].map(c => `<div style="background:${c[1]};color:${c[2]};border-radius:16px;padding:22px 10px 8px;border:2px solid #F0E6D6">${c[0]}<br><span style="opacity:.8;font-weight:700">${c[1]}</span></div>`).join('')}</div>
  <h2 style="margin:22px 0 8px">Tipografía</h2><div class="card"><div style="font:900 32px Nunito">Nunito Black · Títulos</div><div style="font:600 16px Nunito;margin-top:4px;color:var(--muted)">Nunito SemiBold · Textos y botones</div><div class="num" style="font-size:30px;font-weight:700;margin-top:6px">₲ 5.000.000 · US$ 650,00</div><div class="small">Inter · Números y tablas (cifras tabulares)</div></div>
  <h2 style="margin:22px 0 10px">Estados de la barra de presupuesto</h2><div style="display:flex;flex-direction:column;gap:10px"><div class="row"><div class="bar grow"><i style="width:45%"></i></div><span class="pill g">En camino</span></div><div class="row"><div class="bar o grow"><i style="width:82%"></i></div><span class="pill o">Cuidado</span></div><div class="row"><div class="bar r grow"><i style="width:100%"></i></div><span class="pill r">Límite</span></div></div></div>
 <div><h2 style="margin-bottom:10px">Botones y chips</h2><div style="display:flex;flex-direction:column;gap:12px"><div class="btn">PRIMARIO</div><div class="btn orange">CELEBRAR / ACCIÓN ESPECIAL</div><div class="btn ghost" style="box-shadow:none">SECUNDARIO</div><div class="row"><span class="chip on">Seleccionado</span><span class="chip">Normal</span><span class="pill g">Etiqueta</span><span class="pill o">${ic('flame')} 12</span></div></div>
  <h2 style="margin:22px 0 10px">Finn en cada estado</h2><div class="card" style="display:grid;grid-template-columns:repeat(3,1fr);gap:4px 10px;text-align:center;font-size:12px;font-weight:800;padding:14px 10px">${[['happy', 'Feliz'], ['celebrate', 'Celebra'], ['think', 'Piensa'], ['worry', 'Preocupado'], ['sleep', 'Dormido'], ['rich', 'Rico']].map(p => `<div style="display:flex;flex-direction:column;align-items:center;gap:2px">${finn(p[0], 70)}${p[1]}</div>`).join('')}</div>
  <h2 style="margin:22px 0 10px">Reglas</h2><div class="card" style="font-size:14px;font-weight:700;line-height:1.6">• Esquinas de 16–24 px, sombras suaves<br>• Un número héroe por pantalla<br>• Rojo solo para peligro real<br>• Animaciones de 200–300 ms, respeta "reducir movimiento"<br>• Contraste AA y textos escalables</div></div></div>`;

// 15. Hoja de iconos
S.iconos = () => `<div style="width:1100px;background:#FFF9F0;border-radius:24px;padding:30px;box-shadow:0 20px 50px rgba(40,30,10,.2)"><h1 style="font-size:30px">AltFin · Set de iconos</h1><p class="sub" style="margin:4px 0 18px">Planos, redondeados, a color. Sin emojis. ${Object.keys(ICONS).length} iconos propios.</p><div style="display:grid;grid-template-columns:repeat(8,1fr);gap:14px">${Object.keys(ICONS).map(k => `<div style="text-align:center;font-size:12px;font-weight:800;color:#7A8790"><div style="background:#fff;border-radius:20px;height:96px;display:grid;place-items:center;font-size:56px;box-shadow:0 4px 14px rgba(70,50,20,.08)">${ic(k)}</div><div style="margin-top:6px">${k}</div></div>`).join('')}</div></div>`;

const params = new URLSearchParams(location.search);
const key = params.get('n') || 'inicio';
if (key === 'inicio_oscuro') document.body.classList.add('dark', 'out');
document.getElementById('app').innerHTML = S[key]();
