import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/finance_engine.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';
import '../../util.dart';

/// Informe: últimos 6 meses (ingresos vs gastos), tasa de ahorro y gastos por categoría.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.alt;
    final s = ref.watch(settingsProvider).value;
    final txns = ref.watch(recentTxnsProvider).value ?? const <Txn>[];
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final now = ref.watch(clockProvider)();
    final cur = s.currency;
    Money conv(Txn t) => s.fx.convert(Money(t.amountMinor, Currency.fromCode(t.currency)), cur);

    // 6 meses: del más viejo al actual.
    final months = [for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i)];
    final spent = <int>[];
    final saved = <int>[];
    for (final m in months) {
      var sp = 0, sv = 0;
      for (final t in txns.where((t) => t.date.year == m.year && t.date.month == m.month)) {
        if (t.kind == 'expense') sp += conv(t).minor;
        if (t.kind == 'saving') sv += conv(t).minor;
      }
      spent.add(sp);
      saved.add(sv);
    }
    final income = s.netIncomeMinor;
    final rateNow = FinanceEngine.savingsRate(saved: Money(saved.last, cur), income: Money(income, cur));
    final ratePrev = FinanceEngine.savingsRate(saved: Money(saved[4], cur), income: Money(income, cur));

    // Gasto por categoría del mes actual.
    final byCat = <int?, int>{};
    for (final t in txns.where((t) => t.kind == 'expense' && t.date.year == now.year && t.date.month == now.month)) {
      byCat[t.categoryId] = (byCat[t.categoryId] ?? 0) + conv(t).minor;
    }
    final entries = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final totalSpent = entries.fold<int>(0, (a, e) => a + e.value);
    final palette = [c.blue, c.orange, c.green, const Color(0xFFB58AE8), c.red, const Color(0xFFFFD23F)];
    final catById = {for (final x in cats) x.id: x};

    // Mensaje de Finn: comparación simple contra el mes anterior.
    final prev = spent[4];
    String insight;
    if (prev > 0 && spent.last > 0) {
      final diff = ((spent.last - prev) / prev * 100).round();
      insight = diff <= 0
          ? 'Gastaste ${-diff} % menos que el mes pasado. ¡Seguí así!'
          : 'Gastaste $diff % más que el mes pasado. Miremos juntos en qué.';
    } else {
      insight = 'Anotá tus gastos unos días y te cuento cómo vas.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Informe', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        AltCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TASA DE AHORRO', style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
                Text('${(rateNow * 100).round()} %', style: numStyle(34, color: c.greenDark)),
              ]),
              const Spacer(),
              if (ratePrev > 0 || rateNow > 0)
                Pill('${rateNow >= ratePrev ? '+' : '−'}${((rateNow - ratePrev).abs() * 100).round()} pts vs mes anterior',
                    tone: rateNow >= ratePrev ? 'g' : 'o'),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                painter: _BarsPainter(
                  income: income,
                  spent: spent,
                  saved: saved,
                  labels: [for (final m in months) monthName(m).substring(0, 3)],
                  colors: (c.blue, c.orange, c.green, c.muted, c.line),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(children: [
              _legend(c.blue, 'Ingreso'),
              const SizedBox(width: 12),
              _legend(c.orange, 'Gastos'),
              const SizedBox(width: 12),
              _legend(c.green, 'Ahorro'),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        AltCard(
          child: entries.isEmpty
              ? Text('Todavía no hay gastos este mes.', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700))
              : Row(children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CustomPaint(
                      painter: _DonutPainter([for (final e in entries) e.value.toDouble()], palette, c.line),
                      child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(Money(totalSpent, cur).format(withSymbol: false), style: numStyle(13)),
                          Text('gastado', style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(children: [
                      for (var i = 0; i < math.min(entries.length, 5); i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(children: [
                            Container(width: 11, height: 11, decoration: BoxDecoration(color: palette[i % palette.length], borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 8),
                            Expanded(child: Text(catById[entries[i].key]?.name ?? 'Sin categoría', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                            Text('${(entries[i].value / totalSpent * 100).round()}%', style: numStyle(13)),
                          ]),
                        ),
                    ]),
                  ),
                ]),
        ),
        const SizedBox(height: 14),
        MintCard(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            const FinnView(size: 56),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(TextSpan(children: [
                const TextSpan(text: 'Finn te cuenta: ', style: TextStyle(fontWeight: FontWeight.w900)),
                TextSpan(text: insight),
              ]), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _legend(Color color, String text) => Row(children: [
        Container(width: 11, height: 11, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ]);
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.income, required this.spent, required this.saved, required this.labels, required this.colors});

  final int income;
  final List<int> spent, saved;
  final List<String> labels;
  final (Color, Color, Color, Color, Color) colors; // ingreso, gasto, ahorro, texto, línea

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = [income, ...spent, ...saved].reduce(math.max).clamp(1, 1 << 62).toDouble();
    final base = size.height - 20;
    final groupW = size.width / spent.length;
    const barW = 14.0;
    canvas.drawLine(Offset(0, base), Offset(size.width, base), Paint()..color = colors.$5..strokeWidth = 2);
    for (var i = 0; i < spent.length; i++) {
      final cx = groupW * i + groupW / 2;
      void bar(double dx, num v, Color col) {
        final h = (base - 4) * v / maxV;
        if (h <= 0) return;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + dx - barW / 2, base - h, barW, h), const Radius.circular(5)), Paint()..color = col);
      }

      bar(-barW - 2, income, colors.$1);
      bar(0, spent[i], colors.$2);
      bar(barW + 2, saved[i], colors.$3);
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: TextStyle(color: colors.$4, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, base + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter o) => true;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.values, this.palette, this.track);

  final List<double> values;
  final List<Color> palette;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(8);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(r, 0, math.pi * 2, false, paint..color = track);
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = math.pi * 2 * values[i] / total;
      canvas.drawArc(r, start, math.max(0, sweep - 0.03), false, paint..color = palette[i % palette.length]);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter o) => true;
}
