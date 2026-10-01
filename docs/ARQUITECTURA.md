# Arquitectura de AltFin

Resumen de cómo está organizada la app para quien quiera contribuir.

## Capas

```
UI (lib/ui, lib/features/*)         Widgets, pantallas, tema, Finn, iconos
        │  lee/escribe vía Riverpod
Estado (lib/state/providers.dart)   Providers: ajustes, movimientos, resumen del mes…
        │
Datos (lib/data)                    Drift/SQLite: tablas, consultas, copia de seguridad
        │
Dominio (lib/domain)                Reglas puras: dinero, reparto, interés, rachas, PIN, CSV…
```

El **dominio no depende de Flutter ni de la base de datos**: se prueba con `dart test` puro (`flutter test`). La UI nunca calcula dinero por su cuenta; llama al dominio.

## Dinero

- `Money(minor, currency)` guarda enteros: guaraníes (`PYG`, 0 decimales) o centavos de dólar (`USD`, 2 decimales).
- Formato paraguayo: `₲ 1.250.000` y `US$ 650,00` (`Money.format`).
- Conversión ₲ ↔ US$ con una tasa manual editable (`Fx`). No se consultan tipos de cambio en internet.
- El reparto del sueldo (`BudgetSplit`) asigna el redondeo sobrante al ahorro: la suma siempre es exactamente el sueldo.

## Base de datos (Drift)

Archivo `lib/data/database.dart` (más `database.g.dart`, generado y versionado para facilitar el build).

| Tabla | Para qué |
|---|---|
| `Categories` | Categorías de gasto (bloque necesidad/gusto, límite mensual, icono) |
| `Txns` | Movimientos: `expense`, `income`, `saving` |
| `Goals` | Metas de ahorro |
| `Recurrings` | Gastos fijos que se anotan solos |
| `Debts` | Deudas del plan de pago (saldo, tasa anual, mínimo) |
| `DayChecks` | Días marcados "hoy no gasté" (cuentan para la racha) |
| `Settings` | Ajustes clave/valor (sueldo, perfil, XP, PIN hasheado…) |

Si cambiás el esquema: subí `schemaVersion`, agregá el paso en `onUpgrade` y corré `build_runner`.

## Flujo de datos

`Settings + Txns + Categories` → `monthSummaryProvider` (`MonthSummary.compute`) → pantallas.
La hora actual se inyecta con `clockProvider`, lo que permite probar "mitad de mes" sin esperar.

## Funcionalidades transversales

- **Notificaciones** (`lib/services/notification_service.dart`): se agendan los próximos 14 días a la hora elegida, omitiendo hoy si ya registraste. Solo Android por ahora.
- **Bloqueo con PIN** (`features/lock/lock_gate.dart`): pide PIN al abrir y tras 30 s en segundo plano.
- **Copia de seguridad** (`lib/data/backup.dart`): JSON con todas las tablas; restaurar reemplaza todo dentro de una transacción.
- **Deudas**: `DebtPlanner` simula avalancha y bola de nieve en enteros (el total pagado = capital + intereses exacto).
- **Gastos fijos**: `RecurringRule` decide si toca generar el gasto del mes; `generateDueRecurrings` se ejecuta al abrir la app.
- **Adaptación celular/PC** (`features/shell/app_shell.dart`): barra inferior en celular y barra lateral desde 900 px; atajos `Ctrl+N` / `Ctrl+Alt+G`.

## Pruebas

- `test/finance_engine_test.dart`, `test/domain_extras_test.dart`: lógica pura.
- `test/backup_test.dart`: copia y restauración con base en memoria.
- `test/app_flows_test.dart`: recorre la app real con datos de ejemplo (onboarding, anotar gasto, PIN, gastos fijos, escritorio). Con `ALTFIN_SCREENSHOTS=1` regenera las capturas del README.

## Diseño

`diseno/ui/` contiene los mockups (HTML/CSS → PNG), el sistema de diseño y la hoja de iconos. `diseno/finn/` tiene la hoja de personaje. Los iconos de la app salen de `app/lib/ui/icons/icon_paths.dart` (generado desde `diseno/ui/icons.js`).
