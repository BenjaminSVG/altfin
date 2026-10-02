import 'package:flutter/services.dart';

import '../../domain/money.dart';

/// Pone puntos de miles mientras se escribe: 5000000 → 5.000.000.
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = Money(int.parse(digits), Currency.pyg).format(withSymbol: false);
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
