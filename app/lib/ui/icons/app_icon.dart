import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'icon_paths.dart';

/// Icono propio de AltFin (vectorial, a color). Ver `kIconPaths`.
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, this.size = 24});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final inner = kIconPaths[name];
    assert(inner != null, 'Icono desconocido: $name');
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">${inner ?? ''}</svg>',
      width: size,
      height: size,
    );
  }
}
