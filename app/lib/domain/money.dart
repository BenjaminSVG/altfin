/// Monedas soportadas por AltFin. El dinero siempre se guarda como entero
/// en la unidad mínima de la moneda (nunca como double).
enum Currency {
  /// Guaraní paraguayo: sin decimales.
  pyg('PYG', '₲', 0),

  /// Dólar estadounidense: centavos.
  usd('USD', 'US\$', 2);

  const Currency(this.code, this.symbol, this.decimals);

  final String code;
  final String symbol;
  final int decimals;

  int get factor {
    var f = 1;
    for (var i = 0; i < decimals; i++) {
      f *= 10;
    }
    return f;
  }

  static Currency fromCode(String code) =>
      Currency.values.firstWhere((c) => c.code == code);
}

/// Cantidad de dinero inmutable: [minor] está en unidades mínimas
/// (guaraníes enteros, o centavos de dólar).
class Money implements Comparable<Money> {
  const Money(this.minor, this.currency);

  const Money.zero(this.currency) : minor = 0;

  /// Crea dinero desde una cantidad "normal" (p. ej. 12.5 dólares).
  factory Money.fromMajor(num major, Currency currency) =>
      Money((major * currency.factor).round(), currency);

  final int minor;
  final Currency currency;

  double get major => minor / currency.factor;
  bool get isNegative => minor < 0;
  bool get isZero => minor == 0;

  Money operator +(Money o) => Money(minor + _same(o).minor, currency);
  Money operator -(Money o) => Money(minor - _same(o).minor, currency);
  Money operator -() => Money(-minor, currency);

  /// Porcentaje entero (0-100) redondeado hacia abajo.
  Money percent(int pct) => Money(minor * pct ~/ 100, currency);

  /// División entera por [n] (redondeo hacia abajo). Útil para "por día".
  Money divide(int n) {
    if (n <= 0) throw ArgumentError.value(n, 'n', 'debe ser > 0');
    return Money(minor ~/ n, currency);
  }

  Money clampMin(Money min) => this < min ? min : this;

  bool operator <(Money o) => minor < _same(o).minor;
  bool operator >(Money o) => minor > _same(o).minor;
  bool operator <=(Money o) => minor <= _same(o).minor;
  bool operator >=(Money o) => minor >= _same(o).minor;

  Money _same(Money o) {
    if (o.currency != currency) {
      throw ArgumentError('Monedas distintas: $currency y ${o.currency}');
    }
    return o;
  }

  @override
  int compareTo(Money other) => minor.compareTo(_same(other).minor);

  @override
  bool operator ==(Object other) =>
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  /// Formato paraguayo: punto para miles y coma para decimales.
  /// PYG: "₲ 1.250.000"  ·  USD: "US$ 650,00"
  String format({bool withSymbol = true}) {
    final abs = minor.abs();
    final whole = abs ~/ currency.factor;
    final frac = abs % currency.factor;
    final wholeStr = _group(whole);
    final body = currency.decimals == 0
        ? wholeStr
        : '$wholeStr,${frac.toString().padLeft(currency.decimals, '0')}';
    final sign = minor < 0 ? '-' : '';
    return withSymbol ? '$sign${currency.symbol} $body' : '$sign$body';
  }

  static String _group(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  String toString() => format();
}
