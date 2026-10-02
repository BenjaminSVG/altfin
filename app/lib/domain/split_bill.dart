/// Cálculos para dividir gastos entre amigos (estilo Splitwise), sin decimales
/// perdidos: las partes siempre suman exactamente el total.
class SplitBill {
  const SplitBill._();

  /// Reparte [totalMinor] en [people] partes iguales. Si no divide exacto, las
  /// primeras personas reciben una unidad más (así la suma es el total).
  static List<int> equalShares(int totalMinor, int people) {
    if (people <= 0) return const [];
    final base = totalMinor ~/ people;
    final extra = totalMinor % people;
    return [for (var i = 0; i < people; i++) base + (i < extra ? 1 : 0)];
  }

  /// Texto del saldo con un amigo: >0 te debe, <0 le debés, 0 están a mano.
  static String describe(String name, int balanceMinor, String formatted) {
    if (balanceMinor > 0) return '$name te debe $formatted';
    if (balanceMinor < 0) return 'Le debés $formatted a $name';
    return 'Están a mano con $name';
  }
}
