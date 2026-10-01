import 'money.dart';

/// Conversión simple entre guaraníes y dólares con una tasa manual
/// ([pygPerUsd] = guaraníes por 1 dólar). El usuario la puede editar.
class Fx {
  const Fx(this.pygPerUsd);

  /// Tasa de referencia inicial (editable en Ajustes).
  static const defaultRate = 7300.0;

  final double pygPerUsd;

  Money convert(Money m, Currency to) {
    if (m.currency == to) return m;
    if (m.currency == Currency.usd && to == Currency.pyg) {
      return Money((m.minor / 100 * pygPerUsd).round(), Currency.pyg);
    }
    // PYG -> USD (centavos)
    return Money((m.minor / pygPerUsd * 100).round(), Currency.usd);
  }
}
