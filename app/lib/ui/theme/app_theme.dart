import 'package:flutter/material.dart';

/// Colores de AltFin (ver diseno/ui/base.css).
@immutable
class AltColors extends ThemeExtension<AltColors> {
  const AltColors({
    required this.bg,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.green,
    required this.greenDark,
    required this.greenSoft,
    required this.orange,
    required this.orangeSoft,
    required this.red,
    required this.redSoft,
    required this.blue,
    required this.blueSoft,
    required this.purpleSoft,
  });

  final Color bg, card, ink, muted, line;
  final Color green, greenDark, greenSoft;
  final Color orange, orangeSoft, red, redSoft, blue, blueSoft, purpleSoft;

  static const light = AltColors(
    bg: Color(0xFFFFF9F0),
    card: Colors.white,
    ink: Color(0xFF24313A),
    muted: Color(0xFF7A8790),
    line: Color(0xFFF0E6D6),
    green: Color(0xFF2FB67C),
    greenDark: Color(0xFF1F8F5F),
    greenSoft: Color(0xFFDDF5E9),
    orange: Color(0xFFFF9F43),
    orangeSoft: Color(0xFFFFEBD3),
    red: Color(0xFFF25F5C),
    redSoft: Color(0xFFFFE1E0),
    blue: Color(0xFF4DA3FF),
    blueSoft: Color(0xFFDEEEFF),
    purpleSoft: Color(0xFFEBDDFB),
  );

  static const dark = AltColors(
    bg: Color(0xFF12171A),
    card: Color(0xFF1C2327),
    ink: Color(0xFFF2F5F4),
    muted: Color(0xFF8FA0A8),
    line: Color(0xFF2A343A),
    green: Color(0xFF4FD39A),
    greenDark: Color(0xFF2FB67C),
    greenSoft: Color(0xFF1B3A2E),
    orange: Color(0xFFFFB366),
    orangeSoft: Color(0xFF3A2C1B),
    red: Color(0xFFFF7A77),
    redSoft: Color(0xFF3B2222),
    blue: Color(0xFF6DB6FF),
    blueSoft: Color(0xFF1B2C3E),
    purpleSoft: Color(0xFF2E2340),
  );

  @override
  AltColors copyWith() => this;

  @override
  AltColors lerp(ThemeExtension<AltColors>? other, double t) => this;
}

extension AltTheme on BuildContext {
  AltColors get alt => Theme.of(this).extension<AltColors>()!;
}

class AppTheme {
  const AppTheme._();

  static ThemeData build(Brightness brightness) {
    final c = brightness == Brightness.dark ? AltColors.dark : AltColors.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: c.green,
      brightness: brightness,
    ).copyWith(primary: c.green, surface: c.card, onSurface: c.ink);
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      fontFamily: 'Nunito',
      extensions: [c],
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: c.ink, displayColor: c.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerColor: c.line,
    );
  }
}

/// Texto numérico con cifras tabulares (Inter).
TextStyle numStyle(double size, {FontWeight weight = FontWeight.w800, Color? color}) =>
    TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.02 * size,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
