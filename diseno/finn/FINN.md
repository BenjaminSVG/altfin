# Finn — mascota de AltFin

Hoja visual: [finn-hoja-de-personaje.svg](finn-hoja-de-personaje.svg) (ábrela en el navegador).

## Concepto
Un peluche circular, suave, con cara amigable. Es una bola perfecta (como un peluche de tela) con costura visible, bracitos y piecitos cortos, y una **moneda-brote** dorada en la cabeza que simboliza que el dinero crece.

## Diseño
- Cuerpo: círculo verde menta, degradado `#7BE0B2 → #2FB67C → #1F8F5F`.
- Cara: ojos grandes con brillo, mejillas rosadas `#FF8FA3`, sonrisa pequeña.
- Moneda-brote: dorado `#FFE98A → #E8A317`, símbolo `$` (en la app se cambia a **₲** según moneda).
- Fondo de marca: crema `#FFF4E0`. Acento: naranja `#FF9F43`. Texto: `#24313A`.
- Tipografía de marca: Nunito.

## Personalidad y voz
Amable, tranquilo, un poco bromista; nunca regaña. Español de Paraguay (tuteo/voseo neutro, sin exagerar jergas), frases cortas, máximo 1 emoji.
Ejemplos: "¡Anotaste tu terere de hoy! Cada registro suma." · "Tu fondo de emergencia ya cubre 2,1 meses." · "Hoy gastaste ₲ 0 en gustos. Finn está orgulloso."

## Estados (mapa a animaciones Rive)
| Estado | Disparador |
|---|---|
| Feliz | Dentro del presupuesto |
| Celebrando | Meta cumplida, racha, nivel nuevo |
| Pensativo | Gasto grande / dudas |
| Preocupado (suave) | Cerca del límite (80–100 %) |
| Dormido | Fuera de horario / sin actividad |
| Rico | Niveles altos (sombrero de copa y monóculo) |

## Evolución por nivel
Finn Brote (1–9) → Finn Estudiante (10–19, mochila) → Finn Ahorrador (20–29, alcancía) → Finn Inversor (30–39, gráfico) → Finn Magnate (40–50, sombrero y monóculo).

## Estado de producción
- [x] Concepto y paleta.
- [x] Hoja de 6 poses en SVG vectorial (hecha a mano en código; sirve como base para Rive/Flutter).
- [ ] Generación con IA de arte final: la herramienta de imágenes requiere un plan superior, no disponible en esta cuenta.
- [ ] Animación en Rive (parpadeo, rebote, confeti) y exportar `.riv`.
- [ ] Atuendos de evolución y accesorios.
