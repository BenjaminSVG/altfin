# AltFin (app)

Finanzas personales con Finn, tu mascota. Flutter (Dart). Android + Windows. Datos 100 % locales (SQLite con Drift).

## Estado (2026-10-01, 44 pruebas, probada en Windows real)

Hecho:
- Motor financiero en Dart puro (`lib/domain`): dinero en enteros (₲ y US$), reparto 50/30/20 y Modo Cohete, gasto diario permitido, interés compuesto, metas, FIRE, XP/niveles/rachas, conversión ₲↔US$. 27 pruebas.
- Base de datos local (`lib/data/database.dart`): categorías, movimientos, metas, días sin gasto, ajustes.
- Pantallas: onboarding (3 pasos), Inicio, Anotar gasto/ingreso/ahorro, Movimientos, Presupuesto, Metas, Simulador de crecimiento, Informe (6 meses + categorías), Gastos fijos (se anotan solos), Finn y logros, Ajustes. Modo oscuro. Adaptable a PC (barra lateral desde 900 px, atajo Ctrl+Alt+G dentro de la app).
- Seguridad: bloqueo con PIN de 4 dígitos (hash con sal, se pide al abrir y tras 30 s en segundo plano). Exportar a CSV. Copia de seguridad y restauración (JSON, en una transacción).
- Ícono de Finn (Android y Windows).
- Notificaciones locales con frases de Finn (`lib/services/notification_service.dart`), **solo Android por ahora**.
- Capturas automáticas de las pantallas reales: `ALTFIN_SCREENSHOTS=1 flutter test test/app_flows_test.dart` → `../diseno/app_capturas/`.

Pendiente / conocido:
- Notificaciones en Windows: el plugin cierra la app al iniciar; hay que investigarlo (¿registro del AUMID?).
- Falta: deudas, huella digital, widgets de pantalla, atajo global de PC (fuera de la app), notificaciones en Windows.
- Probado en Windows real (versión Release): onboarding, anotar gasto con mouse y con teclado (Ctrl+N / Ctrl+Alt+G, números, Enter, Esc), datos que persisten al reabrir, panel de PC.
- La versión Debug de Windows se cuelga en este equipo (sin ventana); usar siempre `flutter build windows --release`.
- Sin probar en teléfono real.

## Comandos

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenera database.g.dart
flutter test
flutter build windows --release   # y abrir buildwindowsdunnerReleaseltfin.exe
flutter build apk --debug
```
