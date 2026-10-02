# Cambios

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/). El proyecto sigue [versionado semántico](https://semver.org/lang/es/).

## [Sin publicar]

### Agregado
- **Retos sin gasto** (Finn y logros): "7 días sin comer afuera", por categoría o todos los gustos; se evalúan solos con tus gastos y dan 150 XP al cumplirse. Base de datos v7. Referencia: Finch y Duolingo.
- **Gastos compartidos** (Metas): dividir una cuenta entre amigos, ver quién le debe a quién, liquidar y anotar tu parte como gasto. Base de datos v6. Referencia: Splitwise.
- **Patrimonio neto** (Metas): lo que tenés (cuentas, efectivo, bienes y plata en metas) menos lo que debés (deudas), en guaraníes o dólares, con evolución mes a mes. Base de datos v5; la copia de seguridad lo incluye. Referencia: Monarch.
- **Fondo de emergencia** (Metas): calcula gasto esencial mensual × 3, 6 o 9 meses (regla 3-6-9) y crea o actualiza la meta con un toque. Referencia: calculadoras de fondo de emergencia y metas de YNAB/Monarch.

## [0.3.0] — 2026-10-01

### Agregado
- **Nada es obligatorio en el onboarding:** botón "Omitir" en el sueldo y en el porcentaje de ahorro (por ejemplo, si la persona está desempleada). El sueldo se puede cargar o quitar después en Ajustes → "Sueldo y plan de ahorro".
- **Plan de ahorro flexible:** además de Modo Cohete y Equilibrado, ahora hay **Personalizado** (porcentajes propios; el ahorro es lo que sobra y puede ser 0 %) y **Sin porcentaje** (no fijar meta de ahorro).
- **Gastos repetitivos** (autobús, merienda, café...): se define cuántas veces al día, el precio de cada vez y los días de la semana; la app los anota sola cada día y estima el gasto del mes. Incluye el atajo "Autobús".
- La app funciona sin sueldo: el inicio y el presupuesto se adaptan (sin "podés gastar hoy" si no hay ingresos, y sin porcentajes si no hay plan).
- Migración de base de datos a la versión 4; la copia de seguridad incluye los hábitos.
- 80 pruebas automáticas.

## [0.2.0] — 2026-10-01

### Agregado
- Plan de pago de deudas (avalancha y bola de nieve) con pago extra, orden de pago, fecha estimada y comparación de intereses.
- Registrar pagos a una deuda y borrarla.
- La copia de seguridad incluye las deudas (las copias antiguas siguen restaurándose).
- Migración de base de datos a la versión 3.
- Atajo `Ctrl+N` y escritura del monto con el teclado en PC; panel de varias columnas en pantallas anchas.
- 54 pruebas automáticas.

## [0.1.0] — 2026-10-01 (alfa)

Primera versión pública.

### Agregado
- Onboarding (sueldo, frecuencia, día de cobro) y perfiles de ahorro: Modo Cohete (50 %) y Equilibrado (30 %).
- Pantalla de inicio con "Podés gastar hoy", plan del mes, últimos movimientos y racha.
- Anotar gasto, ingreso o ahorro en 3 toques; en PC, con teclado (`Ctrl+N`, números, `Enter`, `Esc`).
- Movimientos, presupuesto por categoría con límites, metas de ahorro y simulador de interés compuesto.
- Gastos fijos que se anotan solos, informe de 6 meses y categorías.
- Finn: niveles, XP, racha, insignias y recordatorios (Android).
- Guaraníes y dólares, con tasa de cambio manual.
- Bloqueo con PIN, copia de seguridad/restauración (JSON) y exportación a CSV.
- Modo oscuro y diseño adaptable a celular y PC.
- 44 pruebas automáticas.

### Conocido
- Las notificaciones no funcionan en Windows.
- Sin probar en teléfono real.
- La base de datos no está cifrada en disco.
