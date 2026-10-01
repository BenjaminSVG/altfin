# AltFin — App de finanzas personales para hacerte más rico

> **Documento histórico de planificación inicial (2026-10-01).** Algunas decisiones cambiaron después: la mascota es **Finn** (no Capi), la app se llama **AltFin**, es 100 % local y sin Apple. El estado real está en el [README](../README.md) y en [app/README.md](../app/README.md).
Plan completo de producto, diseño, arquitectura y ejecución (móvil + PC)

> **Decisiones confirmadas (2026-10-01):** nombre **AltFin**; mercado **Paraguay**; monedas **Guaraní (PYG, sin decimales) y Dólar (USD)**; **sin Apple** (Android + Windows, Linux opcional); datos **100 % locales** (sin nube ni cuenta; copias de seguridad exportando archivo; el backend de la sección 7.4 y la sincronización quedan descartados).
> Mascota: **Finn**, un peluche circular verde menta con cara amigable (ver `diseno/finn/FINN.md`). Donde el texto de abajo diga "Capi" o "capibara", léase "Finn" (peluche circular); el capibara queda descartado.
> Fecha del plan: 2026-10-01

---------------------------------------------------------------------
## 0. Resumen ejecutivo

- **Qué es:** una app que te dice cada mes cuánto puedes gastar, cuánto ahorrar y cuánto invertir, y te acompaña con una mascota, rachas y notificaciones para que anotes tus gastos.
- **Promesa:** "Ahorra el 50 % de tu sueldo y ve crecer tu patrimonio."
- **Plataformas:** Android, iOS, Windows, macOS, Linux (y web opcional) desde **un solo código**.
- **Tecnología:** Flutter (Dart, compilado a nativo) + base de datos SQLite local + sincronización en la nube opcional. Detalle en la sección 7.
- **Modelo:** gratis con lo esencial; plan "Capi Pro" opcional.

---------------------------------------------------------------------
## 1. Investigación de referencias (apps existentes)

Fuentes consultadas: comparativas de NerdWallet, Kiplinger, CNBC, Forbes (2026). Hallazgos relevantes:

| App | Qué hace bien (copiar la idea) | Qué le falta (oportunidad) |
|---|---|---|
| YNAB | Presupuesto "base cero": asignas cada peso a una categoría | Curva de aprendizaje alta, nada de juego |
| Monarch Money | Presupuesto flexible (fijos / no mensuales / variables), patrimonio neto, informes, metas compartidas, resúmenes semanales | Sin gamificación ni motivación conductual |
| Fintonic / Goodbudget / Mint-like | Categorización, sobres | Frías, enfocadas a "controlar", no a "enriquecerse" |
| Duolingo (referencia de gamificación, no de finanzas) | Mascota, racha diaria, ligas, recordatorios con personalidad, microlecciones | — |
| Finch / Habitica (referencia de hábitos) | Mascota que crece según tus hábitos | — |

**Hueco de mercado:** casi ninguna app de finanzas combina (a) la regla clara "ahorra 50 %", (b) hábito diario con mascota y (c) enfoque en construir patrimonio. Ahí se posiciona Capi.

### Sobre las capturas de pantalla
No pude tomar capturas de otras apps: en esta sesión no tengo herramientas de navegador ni de control de pantalla activas, y copiar capturas con derechos de autor dentro del proyecto tampoco es buena idea. Lo dejé resuelto así:
- La carpeta `referencias/` contiene una **guía de captura** (`referencias/GUIA_CAPTURAS.md`) con qué pantalla capturar de cada app y qué observar.
- Tú (o yo, si activas Claude in Chrome / el navegador integrado) puedes capturar desde las tiendas oficiales (Google Play / App Store) y guardarlas en `referencias/capturas/`.
- Las capturas son **solo moodboard interno**; no se redistribuyen ni se copian elementos con marca.

---------------------------------------------------------------------
## 2. Conceptos financieros del producto

### 2.1 La regla 50 / 30 / 20 adaptada a "ahorra el 50 %"
Meta principal por defecto (editable):

| Bloque | % del sueldo neto | Contenido |
|---|---|---|
| **Necesidades** | 50 % | Renta, comida, servicios, transporte, deudas mínimas |
| **Ahorro + Inversión** | 50 % | Fondo de emergencia, metas, inversión |
| **Gustos** | (sale del bloque 1 o 2 según perfil) | ver perfiles |

Para que sea realista se ofrecen **3 perfiles** al empezar:
1. **Modo Cohete (50 %)**: 50 % ahorro/inversión, 40 % necesidades, 10 % gustos.
2. **Modo Equilibrado (30 %)**: 30 % ahorro, 50 % necesidades, 20 % gustos (regla clásica 50/30/20).
3. **Modo Personalizado**: el usuario mueve los deslizadores.

### 2.2 Flujo de dinero del ahorro
Del bloque de ahorro/inversión, orden de prioridad automático ("cascada"):
1. Fondo de emergencia hasta 3–6 meses de gastos.
2. Pago extra de deudas con interés alto (método avalancha o bola de nieve).
3. Metas con fecha (viaje, laptop, enganche).
4. Inversión a largo plazo (retiro, fondos indexados, etc.).

### 2.3 Fórmulas del motor de cálculo
- `sueldo_neto = sueldo_bruto − impuestos − cuotas` (el usuario puede escribir el neto directo).
- `presupuesto_bloque = sueldo_neto × porcentaje_bloque`.
- `gasto_diario_permitido = (presupuesto_gustos + presupuesto_necesidades_variables − gastado_mes) / dias_restantes`.
- `tasa_ahorro = ahorrado_mes / ingresos_mes`.
- `fondo_emergencia_meses = ahorro_liquido / gasto_mensual_promedio`.
- `interes_compuesto: VF = A × [((1+r/12)^(12n) − 1) / (r/12)]` (aportación mensual A, tasa anual r, n años).
- `patrimonio_neto = activos − pasivos`.
- `independencia_financiera = gasto_anual × 25` (regla del 4 %) y **fecha estimada** para alcanzarla.
- `tiempo_para_meta = (meta − actual) / ahorro_mensual` (con y sin rendimiento).
- Todo con aritmética decimal exacta (nunca `double` para dinero; usar enteros en centavos).

### 2.4 Módulos financieros
1. **Sueldo e ingresos** (mensual, quincenal, semanal, variables, extras).
2. **Gastos** (rápidos, categorizados, recurrentes, suscripciones).
3. **Ahorro** (fondo de emergencia, metas).
4. **Inversión** (cartera manual, aportaciones, simulador de interés compuesto, proyección).
5. **Deudas** (tarjetas, préstamos, plan de pago).
6. **Patrimonio neto** (activos y pasivos).
7. **Simulador "¿Y si…?"** (¿y si ahorro 100 más al mes? ¿y si cancelo esta suscripción?).
8. **Informes** (semanal, mensual, anual, exportar a PDF/CSV).
9. **Educación** (microlecciones de 2 min).

> Importante: la app **no da asesoría financiera regulada**. Mostrar aviso legal y mantener la educación en términos generales.

---------------------------------------------------------------------
## 3. El personaje: **Capi el capibara**

**Por qué un capibara:** animal asociado a calma, amistad y a "llevarse bien con todos"; transmite que ahorrar no tiene que ser estresante. Es distinto del búho de Duolingo y de los cerditos-alcancía típicos.

**Personalidad:** amable, tranquilo, un poco bromista, nunca regaña ni humilla. Celebra los avances pequeños.
**Voz:** cercana, español neutro, frases cortas, 1 emoji máximo.

**Diseño visual:**
- Cuerpo redondeado, color café cálido, mejillas rosadas, gafitas redondas opcionales.
- Lleva una mini bufanda verde (color de marca).
- Una naranja o monedita sobre la cabeza (guiño popular del capibara con naranja).
- Paleta: café `#B8814F`, crema `#FFF4E0`, verde dinero `#2FB67C`, naranja `#FF9F43`.

**Estados / animaciones (Rive o Lottie):**
| Estado | Cuándo | Animación |
|---|---|---|
| Feliz | Dentro de presupuesto | Salta, moneda gira |
| Celebrando | Meta cumplida, racha | Confeti, baila |
| Pensativo | Gasto grande | Se toca la barbilla |
| Preocupado (suave) | Cerca del límite | Gota de sudor, ofrece ayuda |
| Dormido | Fuera de horario | Zzz |
| Rico | Nivel alto | Sombrero de copa, monóculo |

**Evolución:** Capi "crece" y cambia de atuendo con tu nivel (Capi Bebé → Estudiante → Ahorrador → Inversor → Magnate).
**Personalización:** accesorios desbloqueables con monedas del juego (no dinero real).

**Ejemplos de frases:**
- "¡Anotaste tu café! Cada registro cuenta."
- "Hoy llevas $0 en gustos. Capi está orgulloso."
- "Tu fondo de emergencia ya cubre 2.1 meses."

**Producción del personaje:** prompt de diseño → generar hoja de personaje (se puede hacer con las herramientas de imagen disponibles cuando quieras) → vectorizar → animar en Rive.

---------------------------------------------------------------------
## 4. Funcionalidades (por prioridad)

### 4.1 MVP (versión 1.0) — lo imprescindible
1. Onboarding (3 minutos): sueldo, frecuencia de pago, perfil de ahorro, metas, elegir mascota/apodo.
2. **Pantalla de inicio** con: dinero disponible hoy, barra del mes, bloque 50/30/20, Capi.
3. **Registro rápido de gasto** (máximo 3 toques): monto → categoría → guardar. Teclado numérico grande, categorías recientes primero.
4. Categorías con iconos y colores, editables.
5. Ingresos (sueldo + extras).
6. Presupuestos por categoría.
7. Metas de ahorro con barra de progreso.
8. Notificaciones recordatorio (sección 6).
9. Gamificación básica: racha, XP, nivel, insignias.
10. Informes mensuales con gráficas.
11. Datos locales cifrados + exportar CSV.
12. Modo claro / oscuro, español e inglés.

### 4.2 Versión 1.5
- Gastos recurrentes y suscripciones (aviso antes del cobro).
- Deudas y planificador de pago.
- Simulador de interés compuesto e independencia financiera.
- Widgets de pantalla (Android/iOS/Windows) para anotar gasto.
- Sincronización entre dispositivos (nube).
- Escaneo de tickets con OCR en el dispositivo.

### 4.3 Versión 2.0
- Cartera de inversión (manual; luego precios por API).
- Patrimonio neto completo.
- Presupuesto compartido (pareja/familia).
- Lecciones y retos semanales; ligas amistosas opcionales.
- Conexión bancaria (Open Banking / agregadores según país) — opcional y con consentimiento.
- Asistente con IA que responde "¿en qué gasté de más?" usando tus datos.

### 4.4 Ideas extra ("más cosas si es necesario")
- **Reto 52 semanas**, **reto sin gastos hormiga**, **reto del 1 %**.
- **"Costo en horas de trabajo"**: cuánto de tu vida cuesta una compra (precio ÷ tu sueldo por hora).
- **Regla de las 24 horas**: lista de deseos que espera un día antes de comprar.
- **Redondeo automático** al ahorro (anotas $47, apartas $3 virtuales).
- **Cápsula del futuro**: "Si ahorras esto 10 años serás $X".
- **Resumen semanal** con Capi (domingo).
- **Bloqueo con huella/PIN**, modo privado (oculta montos).
- **Multi-moneda** y conversión.
- **Calendario de pagos**.
- **Meta "Mi primer millón"** con camino visual.

---------------------------------------------------------------------
## 5. Gamificación (inspirada en Duolingo / Finch / Habitica)

| Mecánica | Regla |
|---|---|
| **Racha** | Días seguidos registrando gastos (o confirmando "hoy no gasté"). Congelador de racha: 1 gratis por semana |
| **XP** | +10 registrar gasto, +25 completar día, +100 cumplir presupuesto semanal, +500 meta cumplida |
| **Niveles** | 1–50; cada nivel desbloquea accesorios de Capi y lecciones |
| **Monedas Capi** | Moneda virtual para la tienda de accesorios (no es dinero real) |
| **Insignias** | "Primer ahorro", "7 días", "Fondo de emergencia 1 mes", "Deuda cero", "Primer 1000 invertido"… |
| **Retos semanales** | Ejemplo: "Gasta menos de $X en comida fuera" |
| **Mapa del camino** | Camino ilustrado hacia la libertad financiera con hitos |
| **Ligas (opcional)** | Compararse con amigos solo en **hábitos**, nunca mostrando cantidades |

**Reglas éticas:** nada de culpa ni presión tóxica; la racha nunca se castiga con pérdidas de dinero; el usuario puede desactivar todo el juego.

---------------------------------------------------------------------
## 6. Notificaciones

**Objetivo:** que el usuario anote sus gastos sin molestarle.

| Tipo | Ejemplo | Disparador |
|---|---|---|
| Recordatorio diario | "¿Qué tal el día? Anota tus gastos 🦫" | Hora elegida (por defecto 8:00 pm) |
| Inteligente | Si ya registró hoy, no se envía | Lógica local |
| Racha en peligro | "Tu racha de 12 días termina esta noche" | 2 h antes de medianoche |
| Después de comer | "¿Comiste fuera? Anótalo en 5 segundos" | Horarios típicos de comida (opcional) |
| Presupuesto | "Llevas el 80 % de Gustos" | Umbrales 50/80/100 % |
| Día de pago | "¡Llegó tu sueldo! Reparte tu 50 %" | Fecha de sueldo |
| Suscripciones | "Mañana se cobra Netflix" | 1 día antes |
| Resumen semanal | "Tu semana con Capi" | Domingo |
| Metas | "Estás al 75 % de tu viaje" | Hitos |

**Reglas:** máximo 2 por día; horas de silencio; el usuario controla cada tipo; copy amable y variado; aprender la mejor hora según cuándo suele registrar.

**Acciones desde la notificación:** botones "+ Gasto", "Hoy no gasté".
**Implementación:** notificaciones locales (`flutter_local_notifications`) para recordatorios; push (FCM/APNs) solo para cosas del servidor. Escritorio: notificaciones nativas de Windows/macOS.

---------------------------------------------------------------------
## 7. Tecnología y arquitectura

### 7.1 Decisión de lenguaje/framework

| Opción | Pros | Contras | Veredicto |
|---|---|---|---|
| **Flutter (Dart)** | Un solo código para móvil + Windows/macOS/Linux; UI idéntica; compilación AOT a nativo; Impeller (60 fps); excelente para animaciones y gráficos; rápido de desarrollar | Binario algo mayor; desktop menos maduro que móvil | **Elegido** |
| Kotlin Multiplatform + Compose | Rendimiento casi nativo; comparte lógica | Más lento de montar; iOS/desktop menos pulido | Alternativa |
| Tauri 2 (Rust + web) | Muy ligero en PC | Soporte móvil aún experimental | Descartado para v1 |
| React Native | Gran comunidad | Desktop menos sólido | Descartado |

Según comparativas de 2026, Flutter y KMP son indistinguibles para el usuario en la mayoría de apps, y Flutter permite arrancar MVPs 2–3 veces más rápido.

**Lenguajes a usar:**
- **Dart** (toda la app).
- **Rust** *(opcional, fase posterior)* para el motor de cálculo si se requiere cálculo pesado (simulaciones Monte Carlo), expuesto con `flutter_rust_bridge`. En el MVP el motor se escribe en Dart puro y probado.
- **SQL** (SQLite) para datos locales.
- **TypeScript o Dart** para el backend (ver 7.3).

### 7.2 Arquitectura (por capas, offline-first)

```
UI (Flutter widgets, Rive)
   ↓
Estado: Riverpod (providers, notifiers)
   ↓
Dominio: casos de uso + motor financiero (Dart puro, sin Flutter)
   ↓
Datos: repositorios → Drift (SQLite cifrado con SQLCipher)
                      ↘ Sincronizador → Backend (opcional)
```

Principios: **offline-first**, el dinero siempre en **enteros (centavos)**, moneda guardada con cada movimiento, `uuid` para ids, tablas con `updated_at` y `deleted_at` para sincronizar, pruebas unitarias del motor ≥ 90 %.

### 7.3 Paquetes principales
| Necesidad | Paquete |
|---|---|
| Estado | `flutter_riverpod` |
| Navegación | `go_router` |
| Base de datos | `drift` + `sqlcipher_flutter_libs` |
| Modelos | `freezed`, `json_serializable` |
| Gráficas | `fl_chart` |
| Animación de mascota | `rive` |
| Notificaciones | `flutter_local_notifications`, `timezone` |
| Tareas en segundo plano | `workmanager` (móvil) |
| Seguridad | `local_auth`, `flutter_secure_storage` |
| Ventanas de escritorio | `window_manager`, `tray_manager` |
| Idiomas | `flutter_localizations` + ARB |
| OCR | `google_mlkit_text_recognition` (móvil) |
| Compras | `purchases_flutter` (RevenueCat) |
| Análisis | PostHog o Firebase Analytics (con consentimiento) |
| Errores | Sentry |

### 7.4 Backend (solo para sincronizar, login y suscripción)
- **Supabase** (Postgres + Auth + Row Level Security) o Firebase. Recomendado Supabase por SQL y precio.
- Datos cifrados en tránsito; opción de **cifrado de extremo a extremo** en v2.
- La app funciona 100 % sin cuenta.

### 7.5 Adaptación móvil vs PC
| Aspecto | Móvil | PC |
|---|---|---|
| Navegación | Barra inferior | Barra lateral |
| Registro de gasto | Pantalla completa, teclado grande | Atajo global (Ctrl+Alt+G) abre ventana pequeña |
| Inicio | Una columna | Panel con 2–3 columnas, tablas |
| Entradas | Toque, gestos | Ratón, teclado, atajos |
| Extras | Widgets, cámara OCR | Bandeja del sistema, importar CSV, informes grandes |
Se logra con `LayoutBuilder` y breakpoints (<600, 600–1000, >1000 px).

### 7.6 Rendimiento (metas medibles)
- Arranque en frío < 1.5 s en gama media.
- 60 fps constantes (120 en pantallas altas).
- Registrar un gasto en < 5 s desde abrir la app.
- APK < 35 MB; instalador Windows < 60 MB.
- Consultas a 100 000 movimientos < 100 ms (índices por fecha y categoría).

### 7.7 Seguridad y privacidad
- Cifrado SQLCipher en disco; llave en Keychain/Keystore.
- PIN / huella / Face ID.
- Sin vender datos. Política de privacidad clara; cumplir GDPR/LGPD/leyes locales; exportar y borrar datos del usuario.
- Revisión de seguridad antes del lanzamiento.

---------------------------------------------------------------------
## 8. Modelo de datos (tablas principales)

```
user_profile(id, nombre, moneda, pais, idioma, creado_en)
income_source(id, nombre, monto_centavos, frecuencia, dia_pago, activo)
account(id, nombre, tipo[efectivo|banco|tarjeta|inversion], saldo_inicial_centavos, moneda)
category(id, nombre, icono, color, bloque[necesidad|gusto|ahorro|inversion], presupuesto_centavos, orden)
transaction(id, account_id, category_id, tipo[gasto|ingreso|transferencia], monto_centavos,
            fecha, nota, es_recurrente, recurring_id, ticket_foto_uri, creado_en, updated_at, deleted_at)
recurring(id, plantilla_transaccion, regla_repeticion, proxima_fecha)
budget_plan(id, mes, ingreso_neto_centavos, pct_necesidades, pct_gustos, pct_ahorro, pct_inversion)
goal(id, nombre, meta_centavos, actual_centavos, fecha_objetivo, prioridad, icono)
debt(id, nombre, saldo_centavos, tasa_anual, pago_minimo_centavos, dia_pago)
investment(id, nombre, tipo, unidades, costo_promedio_centavos, valor_actual_centavos)
game_state(xp, nivel, racha_actual, racha_max, monedas, congeladores, ultimo_dia_registrado)
badge_unlocked(badge_id, fecha)
reminder_setting(tipo, activo, hora, dias)
```

---------------------------------------------------------------------
## 9. Diseño de interfaz (UI/UX)

### 9.1 Principios (tomados de las referencias)
1. **Un número héroe** en el inicio: "Puedes gastar hoy: $320" (de Monarch/YNAB, simplificado).
2. **Registro en 3 toques** (lo más importante de la app).
3. **Color con significado:** verde = bien, naranja = cuidado, rojo solo para peligro real.
4. **Mascota presente pero no estorbosa** (de Duolingo): ocupa espacio fijo en inicio y celebraciones.
5. **Progreso visible siempre** (barras, anillos, mapa).
6. **Cero jerga:** "Lo que te queda" en lugar de "saldo disponible no asignado".

### 9.2 Sistema visual
- **Tipografía:** Nunito (redondeada, amigable) para títulos, Inter para números/tablas.
- **Esquinas:** radio 16–24 px. **Sombras** suaves. **Iconos** redondeados (Phosphor / Material Symbols Rounded).
- **Colores:**
  - Primario verde `#2FB67C`; secundario naranja `#FF9F43`; fondo claro `#FFF9F0`; fondo oscuro `#14181B`; texto `#1F2933`.
  - Categorías: paleta de 12 colores accesibles (contraste AA).
- **Animaciones:** 200–300 ms, curvas suaves; confeti y monedas en logros; respetar "reducir movimiento".
- **Accesibilidad:** contraste AA, textos escalables, lectores de pantalla, no depender solo del color.

### 9.3 Mapa de pantallas
1. **Bienvenida / Onboarding** (5 pasos): conoce a Capi → sueldo → perfil de ahorro (50/30/20) → metas → permisos de notificación.
2. **Inicio:** Capi + frase, "Puedes gastar hoy", anillo del mes, 3 bloques (Necesidades / Gustos / Ahorro), racha, botón flotante **＋**.
3. **Añadir gasto/ingreso** (hoja inferior).
4. **Movimientos:** lista agrupada por día, búsqueda, filtros.
5. **Presupuesto:** categorías con barras y sobres.
6. **Metas:** tarjetas con progreso y fecha estimada.
7. **Inversión / Patrimonio:** gráfica de crecimiento, simulador.
8. **Deudas.**
9. **Informes:** mensual, anual, tendencias, exportar.
10. **Capi y logros:** nivel, insignias, tienda de accesorios, retos.
11. **Aprender:** microlecciones.
12. **Ajustes:** moneda, notificaciones, seguridad, datos, tema, idioma, Pro.

### 9.4 Navegación
Móvil: 5 pestañas — Inicio · Movimientos · ＋ · Metas · Capi (Informes dentro de Inicio/Metas).
PC: barra lateral con las mismas secciones + atajos de teclado.

### 9.5 Prototipo
Figma: biblioteca de componentes → wireframes → prototipo clicable → prueba con 5 personas antes de programar pantallas finales.

---------------------------------------------------------------------
## 10. Plan paso a paso

### Fase 0 — Preparación (semana 1)
1. Confirmar nombre, público objetivo (país, moneda inicial) y modelo de negocio.
2. Crear repositorio Git, `README`, licencia, convención de commits.
3. Instalar Flutter, Android Studio, Visual Studio (Windows desktop), Xcode (si hay Mac), Rive.
4. Crear cuentas: Google Play (US$25 una vez), Apple Developer (US$99/año, solo si vas a iOS), Supabase, Sentry.
5. Capturar referencias (sección 1) y armar el moodboard.

### Fase 1 — Diseño (semanas 2–3)
1. Hoja de personaje de Capi y estados clave.
2. Sistema de diseño en Figma (colores, tipografías, componentes).
3. Wireframes de las 12 pantallas.
4. Prototipo clicable y pruebas con 5 usuarios reales; ajustar.

### Fase 2 — Cimientos técnicos (semanas 3–4)
1. `flutter create` con soporte android, ios, windows, macos, linux.
2. Estructura de carpetas: `lib/{core,domain,data,features,ui}`.
3. Configurar Riverpod, go_router, Drift, localización, temas claro/oscuro.
4. CI en GitHub Actions: analizar, probar, compilar.
5. **Motor financiero** (Dart puro) con pruebas: reparto 50/30/20, gasto diario permitido, interés compuesto, metas, FIRE. Ésta es la base de todo.

### Fase 3 — MVP funcional (semanas 5–9)
1. Onboarding y perfil (S5).
2. Ingresos y presupuesto del mes (S5).
3. Registro rápido de gastos + categorías + movimientos (S6).
4. Inicio con número héroe, anillos y bloques (S7).
5. Metas de ahorro (S7).
6. Notificaciones locales + ajustes (S8).
7. Gamificación: racha, XP, insignias, Capi animado (S8–9).
8. Informes y exportar CSV (S9).
9. Cifrado, PIN/huella (S9).

### Fase 4 — Pulido y pruebas (semanas 10–11)
1. Pruebas unitarias, de widgets y de integración.
2. Pruebas en 5 teléfonos reales y 2 PCs.
3. Optimización (perfilador de Flutter DevTools): metas de rendimiento de 7.6.
4. Accesibilidad y textos finales.
5. Beta cerrada (Play Internal Testing / TestFlight / instalador MSIX) con 20–50 personas.

### Fase 5 — Lanzamiento v1.0 (semana 12)
1. Fichas de tienda: capturas, video, descripción, política de privacidad.
2. Publicar Android (Google Play) y Windows (Microsoft Store o instalador); iOS/macOS si hay cuenta.
3. Página web simple + lista de espera.
4. Medir: retención día 1/7/30, % que registra gastos, rachas.

### Fase 6 — Versión 1.5 (meses 4–5) y 2.0 (meses 6–9)
Según sección 4.2 y 4.3, priorizando lo que muestren los datos y comentarios de usuarios.

---------------------------------------------------------------------
## 11. Estructura de carpetas del proyecto

```
finanzas personales/
├─ PLAN.md
├─ referencias/
│  ├─ GUIA_CAPTURAS.md
│  └─ capturas/
├─ diseno/            (Figma exports, personaje, iconos)
├─ app/               (proyecto Flutter)
│  ├─ lib/
│  │  ├─ core/        (tema, constantes, utilidades, dinero)
│  │  ├─ domain/      (entidades, casos de uso, motor financiero)
│  │  ├─ data/        (drift, repositorios, sync)
│  │  ├─ features/    (onboarding, home, transactions, budget, goals, game, reports, settings)
│  │  └─ ui/          (widgets compartidos, mascota)
│  ├─ assets/ (rive, fuentes, imágenes)
│  └─ test/
└─ backend/           (migraciones Supabase, funciones)
```

---------------------------------------------------------------------
## 12. Pruebas y calidad
- **Unitarias:** motor financiero, redondeos, fechas de pago, rachas (≥ 90 %).
- **Widgets/golden:** pantallas clave en claro/oscuro y en 3 anchos.
- **Integración:** flujo "onboarding → anotar gasto → ver inicio".
- **Manuales:** notificaciones en Android 13+ (permiso), ahorro de batería, zonas horarias, cambio de horario.
- **Casos límite:** sueldo variable, mes con 31 días, gastos negativos, cambio de moneda, borrado de categoría con movimientos.

---------------------------------------------------------------------
## 13. Negocio y métricas

**Monetización (sin vender datos):**
- **Gratis:** registro ilimitado, presupuesto, 3 metas, racha, Capi básico.
- **Capi Pro** (≈ US$3–5/mes o US$30/año): metas ilimitadas, sincronización, informes avanzados, simulador FIRE, accesorios exclusivos, IA, presupuesto compartido.
- Sin anuncios.

**Métricas clave:** activación (registra ≥1 gasto el día 1), retención D7/D30, gastos registrados por usuario/semana, racha media, % que cumple su presupuesto, conversión a Pro.

---------------------------------------------------------------------
## 14. Riesgos y mitigación
| Riesgo | Mitigación |
|---|---|
| Usuarios dejan de anotar gastos | Registro en 3 toques, notificaciones inteligentes, racha, OCR, importar bancos |
| Notificaciones molestas | Límite diario, control total, aprendizaje de horario |
| Datos sensibles | Cifrado, offline-first, sin venta de datos |
| Percepción de asesoría financiera | Avisos legales, educación general |
| Desktop menos pulido en Flutter | Probar pronto en Windows, usar `window_manager`, diseño adaptable |
| Sobrealcance | Respetar MVP; todo lo demás a 1.5/2.0 |
| Derechos de imágenes de otras apps | Solo moodboard interno; diseño propio |

---------------------------------------------------------------------
## 15. Próximos pasos inmediatos
1. Confirmar: nombre, país/moneda inicial, ¿publicar en iOS?, ¿quieres cuenta en la nube desde v1?
2. Generar la hoja de personaje de **Capi**.
3. Capturar referencias según `referencias/GUIA_CAPTURAS.md`.
4. Crear el proyecto Flutter y construir el **motor financiero** con pruebas.

Fuentes de investigación: [NerdWallet](https://www.nerdwallet.com/finance/learn/best-budget-apps), [Kiplinger](https://www.kiplinger.com/personal-finance/how-to-save-money/best-budgeting-apps), [CNBC](https://www.cnbc.com/select/best-budgeting-apps/), [Forbes](https://www.forbes.com/advisor/banking/best-budgeting-apps/), [Flutter vs KMP 2026](https://volpis.com/blog/kotlin-multiplatform-vs-flutter/), [Tauri 2](https://v2.tauri.app/).
