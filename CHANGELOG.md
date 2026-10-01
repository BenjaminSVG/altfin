# Cambios

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/). El proyecto sigue [versionado semántico](https://semver.org/lang/es/).

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
