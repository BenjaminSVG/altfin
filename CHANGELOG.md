# Cambios

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/). El proyecto sigue [versionado semántico](https://semver.org/lang/es/).

## [0.5.0-alfa] — 2026-10-03

### Agregado
- **Contraseña y biometría para entrar a la app:** en Ajustes → Seguridad se puede proteger la app con un **PIN de 4 dígitos** o con una **contraseña** (6 a 64 caracteres), y activar el **desbloqueo con huella, rostro o Windows Hello**. Al abrir la app pide la huella enseguida; si se cancela o falla, queda el PIN o la contraseña de respaldo. Tras 5 intentos fallidos hay que esperar 30 s (luego 2 y 10 min). La clave no se guarda: solo un hash con sal. Cambiar o quitar el bloqueo pide la clave actual. Probado en el emulador de Android con un sensor de huella virtual (activar, entrar, cancelar, clave incorrecta y correcta).
- **Mi balance:** cargás una vez cuánto dinero tenés y la app lo mantiene al día: suma tus ingresos y resta tus gastos y ahorros. Ves lo que entró, salió y ahorraste **hoy, esta semana, este mes o este año**, el gasto promedio por día, cuántos días te alcanza el dinero a ese ritmo y en qué categorías se fue. Está en el inicio y en Metas. Si cobrás tu sueldo, un toque lo anota (no se duplica en el presupuesto).
- **Gastos periódicos:** cargás a mano lo que gastás **cada día, cada semana o cada mes** (almuerzo, feria, alquiler) y la app lo anota sola cuando corresponde. Muestra el total por día, por semana y por mes; tocá un gasto para cambiar el monto o borrarlo. Reúne los gastos repetitivos y los fijos en una sola pantalla.
- **Widgets directos de Android:** cada botón abre directo lo que dice. El widget "Anotar" ahora tiene tres botones (gasto, ingreso, ahorro) que abren esa pantalla ya en ese tipo, y al guardar se vuelve a donde estabas, sin pasar por la app. "Podés gastar hoy" abre el presupuesto; "Racha" abre la pantalla de nuevo gasto si hoy falta, o Finn si ya anotaste. Widget nuevo **"Dinero disponible"**, que abre Mi balance.

### Conocido
- La huella se probó en un emulador de Android con sensor virtual, no en un celular real. Windows Hello compila, pero no se pudo ejecutar para probarlo.
- Como el APK va firmado con una clave de prueba, para pasar de la 0.4.0 a la 0.5.0 hay que desinstalar la anterior: hacé antes una copia de seguridad en Ajustes.

## [0.4.0-alfa] — 2026-10-02

### Agregado
- **Instaladores en GitHub:** al publicar una versión se generan los APK de Android (uno por procesador) y el ZIP de Windows.
- **Varios recordatorios al día:** en Ajustes se pueden poner hasta 6 horas (con minutos), cambiarlas o quitarlas. Las instalaciones viejas conservan su hora.
- **Notificaciones en Windows:** ahora funcionan también en PC (el aviso de prueba y los programados). Los selectores de hora y fecha salen en español.
- Probado en un emulador de Android 15: onboarding, gastos, Metas, dividir gastos, retos, gastos repetitivos (autobús), widgets y notificaciones. Capturas en `diseno/android_emulador/`.
- **Notificaciones en Android:** ahora la app pide el permiso al abrir (en Android 13+ no se pedía nunca y los recordatorios no sonaban) y usa un ícono propio de Finn.
- Los retos nuevos empiezan mañana si hoy ya gastaste en ese rubro (antes nacían perdidos). Metas reorganizada con grilla de herramientas; "Dividir gasto" en pantalla completa.
- **Metas con plazo:** al crear una meta se puede elegir en cuántos meses (3, 6, 12, 24); la tarjeta muestra cuánto ahorrar por mes y si ya vas bien con tu plan.
- **Editar metas:** pulsación larga en una meta para cambiar el plazo, cambiar el monto objetivo o borrarla.
- **Widgets de pantalla de Android:** "Anotar gasto" (un toque abre nuevo gasto), "Podés gastar hoy" (monto del día y botón +) y "Racha". Se actualizan solos con tus datos. Usa `home_widget`. Sin probar todavía en un celular real.
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
