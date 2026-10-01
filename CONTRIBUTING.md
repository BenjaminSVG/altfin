# Cómo contribuir a AltFin

¡Gracias por querer ayudar! AltFin es un proyecto pequeño y abierto: cualquier aporte (código, diseño, traducciones, ideas, reportes de errores) es bienvenido. Al participar aceptás el [Código de conducta](CODE_OF_CONDUCT.md).

## Principios del proyecto

Estas reglas guían las decisiones; si un cambio las rompe, probablemente no encaje:

1. **Local y privado.** Los datos del usuario se quedan en su dispositivo. No se agregan cuentas, servidores, analíticas ni anuncios.
2. **El dinero nunca es `double`.** Se guarda en enteros (guaraníes, o centavos de dólar). Toda la lógica financiera vive en `app/lib/domain` y **debe tener pruebas**.
3. **Sin culpa.** Finn motiva, nunca regaña ni humilla. Los textos son cálidos, cortos y en español de Paraguay (voseo neutro, sin exagerar la jerga).
4. **No es asesoría financiera.** Las simulaciones son orientativas y la app lo dice.
5. **Pensada para celular y PC** desde el primer día.

## Preparar el entorno

```bash
git clone https://github.com/BenjaminSVG/altfin.git
cd altfin/app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Para compilar en Windows usá `flutter build windows --release` (la compilación *debug* puede colgarse en algunos equipos).

## Flujo de trabajo

1. Buscá un [issue](https://github.com/BenjaminSVG/altfin/issues) o abrí uno para discutir la idea antes de un cambio grande.
2. Creá una rama desde `main`: `git checkout -b feat/mi-cambio` (o `fix/...`, `docs/...`).
3. Hacé cambios pequeños y enfocados, con commits claros (se aceptan mensajes en español).
4. Antes de abrir el PR corré `flutter analyze` y `flutter test` desde `app/`. Deben pasar.
5. Abrí el Pull Request usando la plantilla. Si cambia la interfaz, adjuntá capturas.

## Qué se espera en el código

- **Lógica nueva → pruebas nuevas.** Especialmente cálculos de dinero, fechas (meses cortos, cambio de mes) y rachas.
- **Cambios en la base de datos** (`app/lib/data/database.dart`): subí `schemaVersion`, escribí la migración y regenerá con `build_runner`. No rompas las instalaciones existentes.
- **Interfaz**: usá los widgets y colores de `app/lib/ui` (tema claro y oscuro). Nada de emojis como iconos: usá el set propio (`AppIcon`).
- **Textos**: viven en español; si agregás cadenas, mantené el tono de Finn.
- **Estilo**: `flutter analyze` sin errores ni advertencias; formateá con `dart format`.
- **Dependencias**: pensalo dos veces antes de agregar una. Debe tener licencia compatible (MIT/BSD/Apache) y soporte para Android y Windows. Actualizá [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Capturas de pantalla

Las pruebas de flujo pueden regenerar las capturas del README:

```bash
cd app
ALTFIN_SCREENSHOTS=1 flutter test test/app_flows_test.dart   # en PowerShell: $env:ALTFIN_SCREENSHOTS=1; flutter test ...
```

## Diseño e ilustración

El sistema de diseño y la hoja de personaje de Finn están en [`diseno/`](diseno/). Si proponés arte nuevo (atuendos, animaciones, iconos), respetá el estilo: formas redondeadas, planas, colores de la paleta y sin marcas de terceros. Todo el arte se publica bajo la misma licencia MIT.

## Cosas que no se aceptan

- Capturas, marcas o ilustraciones de otras aplicaciones.
- Código que envíe datos del usuario a internet sin que sea una acción explícita suya.
- Contenido que prometa ganancias garantizadas o dé consejos de inversión personalizados.

## ¿Dudas?

Abrí un issue con la etiqueta `pregunta`. ¡Gracias por ayudar a que más gente ahorre mejor!
