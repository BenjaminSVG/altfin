import 'money.dart';

/// Fondo de emergencia: gasto esencial mensual × meses de cobertura.
/// Regla 3-6-9: 3 meses con ingreso estable, 6 con familia o compromisos,
/// 9 si el ingreso es irregular o independiente.
class EmergencyFund {
  const EmergencyFund._();

  static const options = [3, 6, 9];

  static Money target(Money monthlyEssential, int months) => Money(monthlyEssential.minor * months, monthlyEssential.currency);

  /// Cuántos meses de gastos esenciales cubre lo ahorrado (con un decimal).
  static double monthsCovered(Money saved, Money monthlyEssential) =>
      monthlyEssential.minor <= 0 ? 0 : saved.minor / monthlyEssential.minor;

  static double progress(Money saved, Money target) =>
      target.minor <= 0 ? 0 : (saved.minor / target.minor).clamp(0.0, 1.0);
}
