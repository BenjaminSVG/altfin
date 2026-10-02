// Bloqueo de la app: PIN o contraseña, desbloqueo por biometría y espera tras
// varios intentos fallidos. La biometría se simula (no hay sensor en las pruebas).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:altfin/data/database.dart';
import 'package:altfin/domain/pin.dart';
import 'package:altfin/main.dart';
import 'package:altfin/services/biometric_service.dart';
import 'package:altfin/state/providers.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 10, 12, 10, 30);
final _write = Platform.environment['ALTFIN_SCREENSHOTS'] == '1';

class FakeBiometric implements BiometricService {
  FakeBiometric({this.available = true, this.accepts = true});

  bool available;
  bool accepts;
  int asked = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    asked++;
    return accepts;
  }
}

String _iconsPath() {
  final root = Platform.environment['FLUTTER_ROOT'] ?? (Platform.isWindows ? r'C:\src\flutter' : '/');
  return '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
}

Future<void> _loadFonts() async {
  for (final f in [('MaterialIcons', _iconsPath()), ('Nunito', 'assets/fonts/Nunito.ttf'), ('Inter', 'assets/fonts/Inter.ttf')]) {
    final loader = FontLoader(f.$1)..addFont(Future.value(ByteData.sublistView(File(f.$2).readAsBytesSync())));
    await loader.load();
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('reglas', () {
    test('la contraseña pide al menos 6 caracteres y no solo espacios', () {
      expect(PasswordLock.isValidFormat('abc12'), isFalse);
      expect(PasswordLock.isValidFormat('abc123'), isTrue);
      expect(PasswordLock.isValidFormat('      '), isFalse);
      expect(PasswordLock.isValidFormat('a' * 65), isFalse);
      expect(PasswordLock.isValidFormat('mi clave segura!'), isTrue);
    });

    test('verifica PIN y contraseña con su sal, sin guardar la clave', () {
      final salt = PinLock.newSalt();
      final pinHash = PinLock.hash('1234', salt);
      expect(AppLock.verify(LockKind.pin, '1234', salt, pinHash), isTrue);
      expect(AppLock.verify(LockKind.pin, '4321', salt, pinHash), isFalse);
      final pwHash = PinLock.hash('Secreto#9', salt);
      expect(AppLock.verify(LockKind.password, 'Secreto#9', salt, pwHash), isTrue);
      expect(AppLock.verify(LockKind.password, 'secreto#9', salt, pwHash), isFalse);
      expect(pwHash.contains('Secreto'), isFalse);
      // Un hash vacío (sin bloqueo) nunca valida.
      expect(AppLock.verify(LockKind.password, '', salt, ''), isFalse);
    });

    test('espera creciente tras intentos fallidos', () {
      expect([for (final n in [0, 4, 5, 7, 8, 9, 10, 20]) AppLock.lockoutSeconds(n)], [0, 0, 30, 30, 120, 120, 600, 600]);
    });

    test('el tipo de bloqueo se lee de los ajustes (por defecto PIN)', () {
      expect(LockKind.fromId(null), LockKind.pin);
      expect(LockKind.fromId('password'), LockKind.password);
      expect(LockKind.fromId('cualquiera'), LockKind.pin);
    });
  });

  final key = GlobalKey();
  const phone = Size(390, 844);

  Future<void> shot(WidgetTester t, String name) async {
    await t.pump(const Duration(milliseconds: 600));
    if (!_write) return;
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 2);
      final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!;
      File('../diseno/app_capturas/$name.png').writeAsBytesSync(bytes.buffer.asUint8List());
    });
  }

  Future<AppDatabase> freshDb({
    LockKind? kind,
    String secret = '',
    bool biometric = false,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.getSetting('x');
    final salt = PinLock.newSalt();
    await saveSettings(db, {
      'onboarded': '1',
      'name': 'Beni',
      'currency': 'PYG',
      'net_income': '5000000',
      'profile': 'rocket',
      if (kind != null) ...{
        'lock_kind': kind.id,
        'pin_salt': salt,
        'pin_hash': PinLock.hash(secret, salt),
        if (biometric) 'biometric': '1',
      },
    });
    return db;
  }

  Future<void> boot(WidgetTester t, AppDatabase db, FakeBiometric bio) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = phone;
    addTearDown(t.view.reset);
    await t.pumpWidget(RepaintBoundary(
      key: key,
      child: ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => _now),
          biometricProvider.overrideWithValue(bio),
        ],
        child: const AltFinApp(),
      ),
    ));
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 600));
  }

  Future<void> finish(WidgetTester t, AppDatabase db) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
    await t.runAsync(db.close);
    await t.pump(const Duration(seconds: 1));
  }

  Future<void> settle(WidgetTester t) async {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 250)));
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 200));
    }
  }

  setUpAll(_loadFonts);

  testWidgets('con contraseña: pide la clave, avisa si está mal y entra con la correcta', (t) async {
    final db = await freshDb(kind: LockKind.password, secret: 'Secreto#9');
    await boot(t, db, FakeBiometric());
    expect(find.text('Ingresá tu contraseña'), findsOneWidget);
    expect(find.text('PODÉS GASTAR HOY'), findsNothing);
    await shot(t, '33-bloqueo-contrasena');

    await t.enterText(find.byType(TextField), 'incorrecta');
    await t.pump();
    await t.tap(find.text('DESBLOQUEAR'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Contraseña incorrecta, probá de nuevo'), findsOneWidget);
    expect(find.text('PODÉS GASTAR HOY'), findsNothing);

    await t.enterText(find.byType(TextField), 'Secreto#9');
    await t.pump();
    await t.tap(find.text('DESBLOQUEAR'));
    await settle(t);
    expect(find.text('PODÉS GASTAR HOY'), findsOneWidget);
    await finish(t, db);
  });

  testWidgets('con PIN sigue funcionando el teclado numérico', (t) async {
    final db = await freshDb(kind: LockKind.pin, secret: '2468');
    await boot(t, db, FakeBiometric());
    expect(find.text('Ingresá tu PIN'), findsOneWidget);
    for (final d in ['2', '4', '6', '8']) {
      await t.tap(find.text(d));
      await t.pump(const Duration(milliseconds: 100));
    }
    await settle(t);
    expect(find.text('PODÉS GASTAR HOY'), findsOneWidget);
    await finish(t, db);
  });

  testWidgets('con biometría activada entra solo, sin escribir nada', (t) async {
    final db = await freshDb(kind: LockKind.password, secret: 'Secreto#9', biometric: true);
    final bio = FakeBiometric();
    await boot(t, db, bio);
    await t.pump(const Duration(milliseconds: 600));
    expect(bio.asked, 1);
    expect(find.text('PODÉS GASTAR HOY'), findsOneWidget);
    await finish(t, db);
  });

  testWidgets('si la huella falla queda el botón y la clave de respaldo', (t) async {
    final db = await freshDb(kind: LockKind.pin, secret: '1357', biometric: true);
    final bio = FakeBiometric(accepts: false);
    await boot(t, db, bio);
    await t.pump(const Duration(milliseconds: 600));
    expect(bio.asked, 1);
    expect(find.text('Ingresá tu PIN'), findsOneWidget);
    expect(find.text('Usar huella o rostro'), findsOneWidget);
    await shot(t, '34-bloqueo-huella');

    // Reintentar con el botón, ahora sí reconoce.
    bio.accepts = true;
    await t.tap(find.text('Usar huella o rostro'));
    await settle(t);
    expect(bio.asked, 2);
    expect(find.text('PODÉS GASTAR HOY'), findsOneWidget);
    await finish(t, db);
  });

  testWidgets('tras 5 intentos fallidos hay que esperar', (t) async {
    final db = await freshDb(kind: LockKind.password, secret: 'Secreto#9');
    await boot(t, db, FakeBiometric());
    for (var i = 0; i < 5; i++) {
      await t.enterText(find.byType(TextField), 'mala-$i-clave');
      await t.pump();
      await t.tap(find.text('DESBLOQUEAR'));
      await t.pump(const Duration(milliseconds: 300));
    }
    expect(find.textContaining('Demasiados intentos'), findsOneWidget);
    // Aun con la clave correcta, mientras espera no entra.
    await t.enterText(find.byType(TextField), 'Secreto#9');
    await t.pump();
    await t.tap(find.text('DESBLOQUEAR'), warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('PODÉS GASTAR HOY'), findsNothing);
    // Se cancela el temporizador antes de cerrar.
    await finish(t, db);
  });

  testWidgets('en Ajustes > Seguridad se activa una contraseña y después la huella', (t) async {
    final db = await freshDb();
    final bio = FakeBiometric();
    await boot(t, db, bio);
    await t.tap(find.text('Finn').last);
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.byIcon(Icons.settings_rounded));
    await settle(t);
    await t.ensureVisible(find.text('Seguridad'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('PIN, contraseña o huella para abrir la app'), findsOneWidget);
    await t.tap(find.text('Seguridad'));
    await settle(t);
    expect(find.text('SIN BLOQUEO'), findsOneWidget);
    await shot(t, '35-seguridad');

    // Una contraseña muy corta no se acepta.
    await t.tap(find.text('Proteger con contraseña'));
    await t.pump(const Duration(milliseconds: 500));
    await t.enterText(find.byType(TextField), 'corta');
    await t.tap(find.text('Aceptar'));
    await settle(t);
    expect(find.textContaining('al menos 6 caracteres'), findsOneWidget);
    expect(await t.runAsync(() => db.getSetting('pin_hash')), isNull);

    // Una buena, repetida dos veces.
    await t.tap(find.text('Proteger con contraseña'));
    await t.pump(const Duration(milliseconds: 500));
    await t.enterText(find.byType(TextField), 'Secreto#9');
    await t.tap(find.text('Aceptar'));
    await t.pump(const Duration(milliseconds: 500));
    await t.enterText(find.byType(TextField), 'Secreto#9');
    await t.tap(find.text('Aceptar'));
    await settle(t);
    expect(await t.runAsync(() => db.getSetting('lock_kind')), 'password');
    final hash = await t.runAsync(() => db.getSetting('pin_hash'));
    final salt = await t.runAsync(() => db.getSetting('pin_salt'));
    expect(AppLock.verify(LockKind.password, 'Secreto#9', salt!, hash!), isTrue);
    expect(find.text('TU APP ESTÁ PROTEGIDA'), findsOneWidget);

    // Huella: se confirma con el sensor antes de activarse.
    expect(find.text('Huella, rostro o Windows Hello'), findsOneWidget);
    bio.accepts = false;
    await t.tap(find.byType(Switch));
    await settle(t);
    expect(await t.runAsync(() => db.getSetting('biometric')), isNull);
    bio.accepts = true;
    await t.tap(find.byType(Switch));
    await settle(t);
    expect(await t.runAsync(() => db.getSetting('biometric')), '1');
    await finish(t, db);
  });

  testWidgets('quitar el bloqueo pide la clave actual y apaga también la huella', (t) async {
    final db = await freshDb(kind: LockKind.password, secret: 'Secreto#9', biometric: true);
    await boot(t, db, FakeBiometric());
    await t.pump(const Duration(milliseconds: 600)); // entra con la huella
    await t.tap(find.text('Finn').last);
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.byIcon(Icons.settings_rounded));
    await settle(t);
    await t.ensureVisible(find.text('Seguridad'));
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.text('Seguridad'));
    await settle(t);
    await t.tap(find.text('Quitar el bloqueo'));
    await t.pump(const Duration(milliseconds: 500));
    await t.enterText(find.byType(TextField), 'equivocada');
    await t.tap(find.text('Aceptar'));
    await settle(t);
    expect(find.textContaining('Contraseña incorrecta'), findsOneWidget);
    expect(await t.runAsync(() => db.getSetting('pin_hash')), isNotEmpty);

    await t.tap(find.text('Quitar el bloqueo'));
    await t.pump(const Duration(milliseconds: 500));
    await t.enterText(find.byType(TextField), 'Secreto#9');
    await t.tap(find.text('Aceptar'));
    await settle(t);
    expect(await t.runAsync(() => db.getSetting('pin_hash')), '');
    expect(await t.runAsync(() => db.getSetting('biometric')), '0');
    expect(find.text('SIN BLOQUEO'), findsOneWidget);
    await finish(t, db);
  });
}
