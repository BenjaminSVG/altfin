import 'fx.dart';
import 'money.dart';

/// Un activo o una deuda cargada a mano (cuenta, efectivo, auto, préstamo...).
class NetItem {
  const NetItem({required this.isLiability, required this.amount});

  final bool isLiability;
  final Money amount;
}

/// Patrimonio neto = lo que tenés − lo que debés, todo en una moneda.
class NetWorth {
  const NetWorth({required this.assets, required this.liabilities});

  final Money assets;
  final Money liabilities;

  Money get net => assets - liabilities;

  /// [goalsSaved] (plata ya guardada en metas) cuenta como activo y
  /// [debts] (saldos de la pantalla de deudas) como pasivo, sin cargarlos dos veces.
  factory NetWorth.compute({
    required List<NetItem> items,
    required List<Money> goalsSaved,
    required List<Money> debts,
    required Fx fx,
    required Currency cur,
  }) {
    var a = Money.zero(cur);
    var l = Money.zero(cur);
    for (final i in items) {
      final m = fx.convert(i.amount, cur);
      if (i.isLiability) {
        l += m;
      } else {
        a += m;
      }
    }
    for (final g in goalsSaved) {
      a += fx.convert(g, cur);
    }
    for (final d in debts) {
      l += fx.convert(d, cur);
    }
    return NetWorth(assets: a, liabilities: l);
  }

  /// Cambio entre el primer y el último valor de la serie mensual (minor units).
  static int change(List<int> series) => series.length < 2 ? 0 : series.last - series.first;
}
