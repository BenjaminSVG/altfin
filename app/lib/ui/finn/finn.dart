import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Estados de ánimo de Finn, la mascota de AltFin.
enum FinnPose { happy, celebrate, think, worry, sleep, rich }

const _green = '#1F8F5F';
const _ink = '#24313A';

String _line(String d, [num w = 5]) =>
    '<path d="$d" fill="none" stroke="$_ink" stroke-width="$w" stroke-linecap="round"/>';

String _arm(num x, num r) =>
    '<ellipse cx="$x" cy="14" rx="20" ry="14" fill="$_green" transform="rotate($r $x 14)"/>';

String _armUp(num x, num r) =>
    '<ellipse cx="$x" cy="-50" rx="14" ry="22" fill="$_green" transform="rotate($r $x -50)"/>';

const _eyes =
    '<circle cx="-32" cy="-6" r="13" fill="$_ink"/><circle cx="32" cy="-6" r="13" fill="$_ink"/>'
    '<circle cx="-28" cy="-11" r="5" fill="#fff"/><circle cx="36" cy="-11" r="5" fill="#fff"/>'
    '<circle cx="-37" cy="0" r="2.5" fill="#fff"/><circle cx="27" cy="0" r="2.5" fill="#fff"/>';

const _cheeks =
    '<ellipse cx="-58" cy="22" rx="14" ry="9" fill="#FF8FA3" opacity=".7"/>'
    '<ellipse cx="58" cy="22" rx="14" ry="9" fill="#FF8FA3" opacity=".7"/>';

// Moneda-brote con el símbolo ₲ dibujado con trazos.
const _sprout =
    '<path d="M0 -98 Q-4 -112 0 -120" stroke="$_green" stroke-width="5" fill="none" stroke-linecap="round"/>'
    '<circle cx="0" cy="-132" r="17" fill="url(#fc)" stroke="#C98700" stroke-width="3"/>'
    '<path d="M6 -138a7 7 0 1 0 0 9v-3.500h-5" stroke="#C98700" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M-6 -134.500h12" stroke="#C98700" stroke-width="2.200" stroke-linecap="round"/>';

String _faceAndArms(FinnPose pose) {
  switch (pose) {
    case FinnPose.happy:
      return '${_arm(-104, -25)}${_arm(104, 25)}';
    case FinnPose.celebrate:
      return '${_armUp(-100, -30)}${_armUp(100, 30)}';
    case FinnPose.think:
      return _arm(-104, -25);
    default:
      return '${_arm(-104, -25)}${_arm(104, 25)}';
  }
}

String _face(FinnPose pose) {
  switch (pose) {
    case FinnPose.happy:
      return [_eyes, _line('M-20 22 Q0 44 20 22')].join();
    case FinnPose.celebrate:
      return [
        _line('M-45 -4 Q-32 -24 -19 -4', 6),
        _line('M19 -4 Q32 -24 45 -4', 6),
        '<path d="M-26 16 Q0 62 26 16 Z" fill="$_ink"/>',
        '<path d="M-14 34 Q0 46 14 34 Q0 28 -14 34 Z" fill="#FF8FA3"/>',
      ].join();
    case FinnPose.think:
      return [
        '<circle cx="-30" cy="-10" r="13" fill="$_ink"/><circle cx="34" cy="-10" r="13" fill="$_ink"/>',
        '<circle cx="-26" cy="-16" r="5" fill="#fff"/><circle cx="38" cy="-16" r="5" fill="#fff"/>',
        _line('M-48 -34 Q-32 -42 -16 -34', 4),
        _line('M16 -38 Q32 -48 48 -38', 4),
        _line('M-10 30 Q4 26 16 32'),
        '<ellipse cx="52" cy="62" rx="15" ry="12" fill="#2FB67C" stroke="#14704A" stroke-width="2.5"/>',
      ].join();
    case FinnPose.worry:
      return [
        _eyes,
        _line('M-50 -24 L-18 -38'),
        _line('M50 -24 L18 -38'),
        _line('M-22 36 Q-11 26 0 36 Q11 46 22 36'),
        '<path d="M78 -50 Q92 -26 78 -16 Q64 -26 78 -50 Z" fill="#7CC4FF" stroke="#4DA3FF" stroke-width="2"/>',
      ].join();
    case FinnPose.sleep:
      return [
        _line('M-46 -4 Q-32 8 -18 -4', 6),
        _line('M18 -4 Q32 8 46 -4', 6),
        '<ellipse cx="0" cy="34" rx="8" ry="6" fill="$_ink"/>',
        '<path d="M78 -92h22l-22 24h22" stroke="#4DA3FF" stroke-width="7" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
        '<path d="M108 -118h14l-14 16h14" stroke="#4DA3FF" stroke-width="5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
      ].join();
    case FinnPose.rich:
      return [
        _eyes,
        _line('M-20 22 Q0 44 20 22'),
        '<circle cx="32" cy="-6" r="24" fill="#fff" fill-opacity=".25" stroke="#E8A317" stroke-width="4"/>',
        '<path d="M44 14 Q60 40 52 64" fill="none" stroke="#E8A317" stroke-width="3"/>',
      ].join();
  }
}

String finnSvg(FinnPose pose) {
  final rich = pose == FinnPose.rich;
  final extra = rich
      ? '<rect x="-52" y="-112" width="104" height="14" rx="6" fill="$_ink"/>'
          '<rect x="-34" y="-168" width="68" height="62" rx="8" fill="$_ink"/>'
          '<rect x="-34" y="-124" width="68" height="12" fill="#E8A317"/>'
      : '';
  final viewBox = rich ? '-135 -185 270 310' : '-135 -158 270 288';
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="$viewBox">'
      '<defs><radialGradient id="fb" cx="38%" cy="30%" r="80%"><stop offset="0" stop-color="#7BE0B2"/><stop offset=".55" stop-color="#2FB67C"/><stop offset="1" stop-color="#1F8F5F"/></radialGradient>'
      '<radialGradient id="fc" cx="35%" cy="30%" r="80%"><stop offset="0" stop-color="#FFE98A"/><stop offset="1" stop-color="#E8A317"/></radialGradient></defs>'
      '<ellipse cx="-42" cy="100" rx="26" ry="17" fill="$_green"/><ellipse cx="42" cy="100" rx="26" ry="17" fill="$_green"/>'
      '${_faceAndArms(pose)}'
      '<circle r="100" fill="url(#fb)"/>'
      '<path d="M-70 -62 A100 100 0 0 1 20 -98" fill="none" stroke="#fff" stroke-opacity=".45" stroke-width="10" stroke-linecap="round"/>'
      '<path d="M-86 52 A100 100 0 0 0 86 52" fill="none" stroke="$_green" stroke-opacity=".55" stroke-width="3" stroke-dasharray="7 7" stroke-linecap="round"/>'
      '${rich ? '' : _sprout}$_cheeks${_face(pose)}$extra</svg>';
}

/// La mascota Finn. Se puede usar en cualquier pantalla.
class FinnView extends StatelessWidget {
  const FinnView({super.key, this.pose = FinnPose.happy, this.size = 120});

  final FinnPose pose;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(finnSvg(pose), width: size, fit: BoxFit.contain);
  }
}
