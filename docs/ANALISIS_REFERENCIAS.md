# Análisis de referencias visuales para AltFin

Las capturas promocionales de otras apps (Google Play, 2026-10-01) se usaron como moodboard local y **no se incluyen en este repositorio** por derechos de autor de sus dueños. Cada quien puede reunirlas con [GUIA_CAPTURAS.md](GUIA_CAPTURAS.md). No se copian marcas, ilustraciones ni textos.

Importante: son capturas promocionales (pulidas, con datos de ejemplo), no sesiones reales de uso. Para ver flujos completos (onboarding, registro de gasto) hay que instalar las apps.

| App | Qué se ve en las capturas | Qué tomamos para AltFin |
|---|---|---|
| **YNAB** | Fondo azul/violeta oscuro, tarjetas con barras de color verde/amarillo por categoría ("Ready to Assign", "Funded"), anillo de meta al 100 % con mensaje "You're a goal-getter!", gráfica de barras Ingresos vs Gasto | Estados por categoría con barra y etiqueta ("Cubierto / Gastado"); anillo de meta con mensaje de felicitación |
| **Monarch** | Fondo crema, tipografía serif en titulares, tarjetas blancas limpias, diagrama de flujo de efectivo (Sankey), barras de presupuesto con "restante", metas con foto y barra de progreso, gráfica de inversiones | Estética calmada y premium; cada meta con su imagen; número principal grande; presupuesto con "te queda" |
| **Duolingo** | Fondo blanco, botones grandes de colores sólidos (naranja, violeta, verde, azul) con textos cortos, barra de progreso verde arriba, mascota en cada pantalla, ilustraciones de personajes | Botones grandes y redondeados; **una mascota en cada pantalla clave**; barra de progreso superior; copy corto y juguetón |
| **Finch** | Fondo celeste, mascota gigante y expresiva, ilustración suave, listas de hábitos con checks, interacción con amigos | Mascota como protagonista; chequeo diario con checks; tono cálido y de cuidado |
| **Wallet (BudgetBakers)** | Fondo gris claro, acento verde y azul, anillo de categorías, barras por periodo, presupuestos con barra de color que cambia (verde → naranja → rojo), metas con ícono | Código de color de barras de presupuesto; metas con ícono (auto, casa, viaje) |
| **Spendee** | Anillo de gasto por categoría con íconos, categorización automática, "Smart insights" con mensaje diario, gráfica de salud financiera | Anillo de categorías con íconos; tarjeta de "insight del día" (aquí hablaría Finn) |
| **Fintual** | Muy minimalista, azul claro, gráfica de crecimiento como héroe, metas por nombre ("Vacaciones", "Mi retiro"), nivel de riesgo, textos en español | Gráfica de crecimiento limpia para inversión/metas a largo plazo; metas con nombre propio; español claro |
| **Robinhood** | Modo oscuro negro con acento verde neón, gráficos de línea con colores vivos, anillos de progreso | Modo oscuro profundo con acento verde (combina con el verde menta de Finn) |

## Decisiones de diseño derivadas
1. **Pantalla de inicio:** número principal enorme "Hoy podés gastar ₲ X" (Monarch/Wallet) + Finn visible (Duolingo/Finch).
2. **Botones:** grandes, muy redondeados, colores sólidos, texto corto (Duolingo).
3. **Barras de presupuesto:** verde → naranja → rojo según el uso (Wallet/YNAB), siempre con texto "te quedan ₲ X".
4. **Metas:** tarjeta con ícono o foto + anillo o barra + mensaje de Finn al llegar al 100 % (YNAB/Monarch).
5. **Categorías:** anillo con íconos redondeados (Spendee/Wallet).
6. **Insight diario:** tarjeta de "Finn te cuenta" (Spendee).
7. **Inversión/patrimonio:** gráfica de línea limpia con rangos 1M/6M/1A (Fintual/Robinhood).
8. **Modo oscuro:** negro suave con acento menta, no neón agresivo (Robinhood).
9. **Fondo claro:** crema `#FFF4E0` en lugar del blanco frío, para diferenciarnos y reforzar la calidez.
10. **Tipografía:** Nunito redondeada para títulos; números en una tipografía tabular (Inter).

## Lo que evitamos
- La densidad de YNAB y de Wallet para principiantes.
- La frialdad de Robinhood/Fintual: sin mascota ni celebraciones.
- Los banners de bancos y el ruido de las capturas de Spendee.
