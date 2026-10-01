import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/finance_engine.dart';
import '../../domain/money.dart';
import '../../state/providers.dart';
import '../../ui/finn/finn.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/widgets.dart';

/// Simulador de interés compuesto: cuánto crece tu plata.
class GrowScreen extends ConsumerStatefulWidget {
  const GrowScreen({super.key});

  @override
  ConsumerState<GrowScreen> createState() => _GrowScreenState();
}

class _GrowScreenState extends ConsumerState<GrowScreen> {
  double monthlyUnits = 1000000;
  double rate = 8;
  double years = 10;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final cur = ref.watch(settingsProvider).value?.currency ?? Currency.pyg;
    final maxMonthly = cur == Currency.pyg ? 10000000.0 : 2000.0;
    if (cur == Currency.usd && monthlyUnits > maxMonthly) monthlyUnits = 100;
    final monthly = Money((monthlyUnits * cur.factor).round(), cur);
    final y = years.round();
    final fv = FinanceEngine.futureValue(monthlyContribution: monthly, annualRatePct: rate, years: y);
    final put = FinanceEngine.totalContributed(monthlyContribution: monthly, years: y);
    final interest = fv - put;
    final points = [
      for (var i = 0; i <= y; i++)
        FinanceEngine.futureValue(monthlyContribution: monthly, annualRatePct: rate, years: i).minor.toDouble(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Crecer', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        AltCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('EN $y ${y == 1 ? 'AÑO' : 'AÑOS'} PODRÍAS TENER',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w800, fontSize: 12)),
            FittedBox(child: Text(fv.format(), style: numStyle(36, color: c.greenDark))),
            const SizedBox(height: 4),
            Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text('Aportás ${put.format()}',
                  style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 12)),
              Pill('+${interest.format()} de interés'),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(painter: _CurvePainter(points, c.green, c.line)),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        AltCard(
          child: Column(children: [
            _slider('Aporte mensual', monthly.format(), monthlyUnits, 0, maxMonthly,
                (v) => setState(() => monthlyUnits = (v / (cur == Currency.pyg ? 100000 : 10)).round() *
                    (cur == Currency.pyg ? 100000.0 : 10.0)), c),
            _slider('Rendimiento anual', '${rate.toStringAsFixed(rate == rate.roundToDouble() ? 0 : 1)} %', rate, 0, 20,
                (v) => setState(() => rate = (v * 2).round() / 2), c),
            _slider('Años', '$y', years, 1, 40, (v) => setState(() => years = v.roundToDouble()), c),
          ]),
        ),
        const SizedBox(height: 14),
        const MintCard(
          padding: EdgeInsets.all(12),
          child: Row(children: [
            FinnView(pose: FinnPose.rich, size: 60),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'El interés compuesto trabaja más cuanto antes empezás. ¡Cada mes cuenta!',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Text('Simulación orientativa. No es asesoría financiera.',
            textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _slider(String label, String value, double v, double min, double max, ValueChanged<double> on, AltColors c) {
    return Column(children: [
      Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        const Spacer(),
        Text(value, style: numStyle(15, color: c.greenDark)),
      ]),
      Slider(value: v.clamp(min, max), min: min, max: max, onChanged: on, activeColor: c.green, inactiveColor: c.line),
    ]);
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter(this.pts, this.color, this.base);

  final List<double> pts;
  final Color color, base;

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) return;
    final maxV = pts.reduce((a, b) => a > b ? a : b);
    if (maxV <= 0) return;
    Offset p(int i) =>
        Offset(size.width * i / (pts.length - 1), size.height - 6 - (size.height - 12) * pts[i] / maxV);
    final line = Path()..moveTo(p(0).dx, p(0).dy);
    for (var i = 1; i < pts.length; i++) {
      line.lineTo(p(i).dx, p(i).dy);
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawLine(Offset(0, size.height - 1), Offset(size.width, size.height - 1),
        Paint()
          ..color = base
          ..strokeWidth = 2);
    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withValues(alpha: .35), color.withValues(alpha: 0)])
              .createShader(Offset.zero & size));
    canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    canvas.drawCircle(p(pts.length - 1), 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter old) => old.pts != pts || old.color != color;
}
