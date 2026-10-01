import 'package:flutter/material.dart';

import '../icons/app_icon.dart';
import '../theme/app_theme.dart';

/// Tarjeta blanca redondeada con sombra suave.
class AltCard extends StatelessWidget {
  const AltCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.gradient,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? c.card) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: borderColor == null ? null : Border.all(color: borderColor!, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x14463214), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: box);
  }
}

/// Tarjeta verde menta (la del "Podés gastar hoy").
class MintCard extends StatelessWidget {
  const MintCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AltCard(
      padding: padding,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const [Color(0xFF1F4D3B), Color(0xFF1B3A2E)]
            : const [Color(0xFFCFF3E2), Color(0xFF9FE5C3)],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: dark ? const Color(0xFFDDF5E9) : const Color(0xFF0F4D33)),
        child: child,
      ),
    );
  }
}

/// Botón grande estilo Duolingo, con "sombra" sólida debajo.
class BigButton extends StatelessWidget {
  const BigButton(this.label, {super.key, required this.onPressed, this.orange = false, this.ghost = false});

  final String label;
  final VoidCallback? onPressed;
  final bool orange;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final bg = ghost ? Colors.transparent : (orange ? c.orange : c.green);
    final shadow = orange ? const Color(0xFFD97F1F) : c.greenDark;
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: ghost ? Border.all(color: c.line, width: 2) : null,
            boxShadow: ghost ? null : [BoxShadow(color: shadow, offset: const Offset(0, 5))],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
              color: ghost ? c.greenDark : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Etiqueta pequeña de color (pill).
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.tone = 'g', this.icon});

  final String text;
  final String tone;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final (bg, fg) = switch (tone) {
      'o' => (c.orangeSoft, c.orange),
      'r' => (c.redSoft, c.red),
      'b' => (c.blueSoft, c.blue),
      _ => (c.greenSoft, c.greenDark),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[AppIcon(icon!, size: 14), const SizedBox(width: 4)],
        Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12)),
      ]),
    );
  }
}

/// Chip seleccionable.
class AltChip extends StatelessWidget {
  const AltChip(this.label, {super.key, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.greenSoft : c.card,
          border: Border.all(color: selected ? c.green : c.line, width: 2),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: selected ? c.greenDark : c.ink,
            )),
      ),
    );
  }
}

/// Barra de progreso redondeada. [tone]: g, o, r, b.
class AltBar extends StatelessWidget {
  const AltBar({super.key, required this.value, this.tone = 'g', this.height = 8});

  final double value;
  final String tone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final color = switch (tone) {
      'o' => c.orange,
      'r' => c.red,
      'b' => c.blue,
      _ => c.green,
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(children: [
        Container(height: height, color: c.line),
        FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(height: height, color: color),
        ),
      ]),
    );
  }
}

/// Cuadrado suave con un icono dentro. [tone]: b, o, g, r, p.
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.tone = 'g', this.size = 42});

  final String icon;
  final String tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final bg = switch (tone) {
      'b' => c.blueSoft,
      'o' => c.orangeSoft,
      'r' => c.redSoft,
      'p' => c.purpleSoft,
      _ => c.greenSoft,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * .33)),
      alignment: Alignment.center,
      child: AppIcon(icon, size: size * .64),
    );
  }
}

/// Anillo de progreso con texto central.
class AltRing extends StatelessWidget {
  const AltRing({super.key, required this.value, required this.child, this.size = 96, this.tone = 'g'});

  final double value;
  final Widget child;
  final double size;
  final String tone;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final color = switch (tone) {
      'o' => c.orange,
      'r' => c.red,
      'b' => c.blue,
      _ => c.green,
    };
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: 1,
            strokeWidth: 11,
            color: c.line,
          ),
        ),
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: 11,
            strokeCap: StrokeCap.round,
            color: color,
          ),
        ),
        child,
      ]),
    );
  }
}

/// Fila de lista: icono + título/subtítulo + monto.
class AmountRow extends StatelessWidget {
  const AmountRow({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.positive = false,
    this.onLongPress,
  });

  final String icon, tone, title, subtitle, amount;
  final bool positive;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    return GestureDetector(
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          IconTile(icon, tone: tone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(subtitle, style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
          ),
          Text(amount, style: numStyle(15, color: positive ? c.greenDark : c.ink)),
        ]),
      ),
    );
  }
}

class Dividers extends StatelessWidget {
  const Dividers({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.alt;
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) out.add(Divider(height: 1.5, thickness: 1.5, color: c.line));
      out.add(children[i]);
    }
    return Column(children: out);
  }
}
