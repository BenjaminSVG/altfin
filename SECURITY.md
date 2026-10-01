# Política de seguridad

## Reportar una vulnerabilidad

**No abras un issue público** para vulnerabilidades. Usá el
[reporte privado de GitHub](https://github.com/BenjaminSVG/altfin/security/advisories/new)
y describí qué pasa, cómo reproducirlo y qué impacto tiene. Te responderemos lo antes posible.

## Qué protege AltFin

- Todos los datos se guardan **solo en el dispositivo** (SQLite). AltFin no tiene servidor ni cuentas, y no envía datos a internet.
- El PIN opcional se guarda como hash SHA-256 con sal, nunca en texto plano.

## Límites conocidos (alfa)

- La base de datos **no está cifrada en disco**; el PIN bloquea la interfaz, no el archivo.
- Las copias de seguridad (`.json`) y las exportaciones (`.csv`) **no están cifradas**: guardalas en un lugar seguro.
- El PIN es de 4 dígitos y no limita los intentos.

Mejorar esto (cifrado de la base de datos, límite de intentos, huella digital) está en la hoja de ruta. Las contribuciones son bienvenidas.

## Versiones soportadas

Mientras el proyecto esté en alfa (0.x), solo se corrigen problemas en la última versión.
