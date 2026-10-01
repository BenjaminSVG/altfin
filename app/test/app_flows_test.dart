// Pruebas de flujo de la app con datos de ejemplo. Con ALTFIN_SCREENSHOTS=1 además genera
// capturas en ../diseno/app_capturas/. Uso: ALTFIN_SCREENSHOTS=1 flutter test test/app_flows_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:altfin/data/database.dart';
import 'package:altfin/domain/gamification.dart';
import 'package:altfin/domain/pin.dart';
import 'package:altfin/main.dart';
import 'package:altfin/state/providers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ruta de la fuente de iconos de Material dentro del SDK de Flutter.
String _materialIconsPath() {
  final root = Platform.environment['FLUTTER_ROOT'] ?? (Platform.isWindows ? r'C:srclutter' : '/');
  return '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
}

/// Las imágenes solo se regeneran a pedido: ALTFIN_SCREENSHOTS=1 flutter test
final _writeShots = Platform.environment['ALTFIN_SCREENSHOTS'] == '1';

final _fixedNow = DateTime(2026, 10, 12, 10, 30);

Future<void> _loadFonts() async {
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File(_materialIconsPath()).readAsBytesSync())));
  await icons.load();
  for (final f in const [('Nunito', 'assets/fonts/Nunito.ttf'), ('Inter', 'assets/fonts/Inter.ttf')]) {
    final loader = FontLoader(f.$1)..addFont(Future.value(ByteData.sublistView(File(f.$2).readAsBytesSync())));
    await loader.load();
  }
}

Future<AppDatabase> _seed({bool onboarded = true, bool dark = false}) async {
  final db = AppDatabase(NativeDatabase.memory());
  await db.getSetting('x'); // fuerza crear tablas y categorías
  if (onboarded) {
    await saveSettings(db, {
      'onboarded': '1',
      'name': 'Beni',
      'currency': 'PYG',
      'net_income': '5000000',
      'profile': 'rocket',
      'xp': '11720',
      'dark': dark ? '1' : '0',
    });
    final now = _fixedNow;
    Future<void> tx(String kind, int amount, int? cat, String note, int daysAgo) => db.addTxn(TxnsCompanion.insert(
          kind: kind,
          amountMinor: amount,
          currency: 'PYG',
          categoryId: Value(cat),
          note: Value(note),
          date: now.subtract(Duration(days: daysAgo)),
        ));
    await tx('income', 5000000, null, 'Sueldo', 0);
    await tx('expense', 1000000, 5, 'Alquiler', 0);
    await tx('expense', 420000, 3, 'Supermercado', 1);
    await tx('expense', 240000, 6, 'ANDE (luz)', 1);
    await tx('expense', 190000, 2, 'Bolt y bus', 2);
    await tx('expense', 235000, 1, 'Tereré y chipa', 3);
    await tx('expense', 75000, 4, 'Cine', 4);
    await tx('saving', 1250000, null, 'Ahorro del mes', 0);
    for (var i = 1; i <= 5; i++) {
      await db.markNoSpendDay(now.subtract(Duration(days: i)));
    }
    // Historial de meses anteriores (informes).
    for (var m = 1; m <= 4; m++) {
      final d = DateTime(now.year, now.month - m, 10);
      await db.addTxn(TxnsCompanion.insert(kind: 'expense', amountMinor: 3200000 + m * 150000, currency: 'PYG', categoryId: const Value(5), date: d));
      await db.addTxn(TxnsCompanion.insert(kind: 'saving', amountMinor: 1800000 + m * 200000, currency: 'PYG', date: d));
    }
    await db.addRecurring(RecurringsCompanion.insert(name: 'Netflix', amountMinor: 45000, currency: 'PYG', categoryId: const Value(9), dayOfMonth: 10));
    await db.addRecurring(RecurringsCompanion.insert(name: 'Internet', amountMinor: 150000, currency: 'PYG', categoryId: const Value(6), dayOfMonth: 15));
    await db.setCategoryLimit(5, 1000000);
    await db.setCategoryLimit(3, 600000);
    await db.setCategoryLimit(1, 280000);
    await db.setCategoryLimit(2, 250000);
    await db.addGoal(GoalsCompanion.insert(name: 'Viaje a Brasil', icon: 'plane', tone: const Value('b'), targetMinor: 5000000, savedMinor: const Value(3400000), currency: 'PYG'));
    await db.addGoal(GoalsCompanion.insert(name: 'Laptop nueva', icon: 'laptop', tone: const Value('o'), targetMinor: 4000000, savedMinor: const Value(1200000), currency: 'PYG'));
    await db.addGoal(GoalsCompanion.insert(name: 'Entrada para terreno', icon: 'villa', tone: const Value('g'), targetMinor: 50000000, savedMinor: const Value(4500000), currency: 'PYG'));
  }
  return db;
}

void main() {
  final out = Directory('../diseno/app_capturas');
  if (_writeShots) out.createSync(recursive: true);
  final key = GlobalKey();

  Future<void> shot(WidgetTester t, String name) async {
    await t.pump(const Duration(milliseconds: 600));
    if (!_writeShots) return;
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 2);
      final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!;
      File('${out.path}/$name.png').writeAsBytesSync(bytes.buffer.asUint8List());
    });
  }

  Future<void> boot(WidgetTester t, AppDatabase db, Size size) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = size;
    addTearDown(t.view.reset);
    await t.pumpWidget(RepaintBoundary(
      key: key,
      child: ProviderScope(overrides: [dbProvider.overrideWithValue(db), clockProvider.overrideWithValue(() => _fixedNow)], child: const AltFinApp()),
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

  const phone = Size(390, 844);

  setUpAll(_loadFonts);

  testWidgets('onboarding', (t) async {
    final db = await _seed(onboarded: false);
    await boot(t, db, phone);
    await shot(t, '01-bienvenida');
    await t.tap(find.text('EMPEZAR'));
    await t.pump(const Duration(milliseconds: 600));
    await t.enterText(find.byType(TextField).first, '5000000');
    await t.pump(const Duration(milliseconds: 600));
    await shot(t, '02-sueldo');
    await t.tap(find.text('CONTINUAR'));
    await t.pump(const Duration(milliseconds: 600));
    await shot(t, '03-perfil');
    await finish(t, db);
  });

  testWidgets('pantallas principales', (t) async {
    final db = await _seed();
    await boot(t, db, phone);
    await shot(t, '04-inicio');
    await t.tap(find.text('Movimientos'));
    await t.pump(const Duration(milliseconds: 600));
    await shot(t, '06-movimientos');
    await t.tap(find.text('Metas'));
    await t.pump(const Duration(milliseconds: 600));
    await shot(t, '08-metas');
    await t.tap(find.text('Finn').last);
    await t.pump(const Duration(milliseconds: 600));
    await shot(t, '11-finn');
    await t.tap(find.text('Inicio'));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Tu plan del mes'));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await shot(t, '07-presupuesto');
    await finish(t, db);
    expect(Gamification.levelForXp(11720), 12);
  });

  testWidgets('añadir gasto', (t) async {
    final db = await _seed();
    await boot(t, db, phone);
    await t.tap(find.byIcon(Icons.add_rounded));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    for (final k in ['3', '5', '000']) {
      await t.tap(find.text(k).first);
      await t.pump();
    }
    await t.tap(find.text('Comida afuera'));
    await t.pump(const Duration(milliseconds: 300));
    await shot(t, '05-gasto');
    await t.tap(find.textContaining('GUARDAR GASTO'));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    final rows = await t.runAsync(() => db.select(db.txns).get());
    expect(rows!.any((r) => r.amountMinor == 35000 && r.kind == 'expense' && r.categoryId == 1), isTrue);
    await finish(t, db);
  });

  testWidgets('gastos fijos, informe y bloqueo con PIN', (t) async {
    final db = await _seed();
    await boot(t, db, phone);
    // Al abrir, el gasto fijo vencido (Netflix, día 10) se anota solo.
    final txs = await t.runAsync(() => db.select(db.txns).get());
    expect(txs!.where((x) => x.note == 'Netflix').length, 1);
    expect(txs.where((x) => x.note == 'Internet').length, 0, reason: 'vence el 15, todavía no');
    await t.tap(find.text('Finn').last);
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.byIcon(Icons.settings_rounded));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await shot(t, '12-ajustes');
    await t.tap(find.text('Gastos fijos y suscripciones'));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await shot(t, '15-gastos-fijos');
    await t.pageBack();
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await t.tap(find.text('Informe'));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await shot(t, '16-informe');
    await finish(t, db);
  });

  testWidgets('bloqueo con PIN', (t) async {
    final db = await _seed();
    final salt = PinLock.newSalt();
    await saveSettings(db, {'pin_salt': salt, 'pin_hash': PinLock.hash('1234', salt)});
    await boot(t, db, phone);
    expect(find.text('Ingresá tu PIN'), findsOneWidget);
    await shot(t, '17-bloqueo');
    for (final k in ['9', '9', '9', '9']) {
      await t.tap(find.text(k));
      await t.pump();
    }
    expect(find.text('PIN incorrecto, probá de nuevo'), findsOneWidget);
    for (final k in ['1', '2', '3', '4']) {
      await t.tap(find.text(k));
      await t.pump();
    }
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Ingresá tu PIN'), findsNothing);
    expect(find.text('PODÉS GASTAR HOY'), findsOneWidget);
    await finish(t, db);
  });

  testWidgets('modo oscuro y escritorio', (t) async {
    final db = await _seed(dark: true);
    await boot(t, db, phone);
    await shot(t, '13-inicio_oscuro');
    await finish(t, db);
    final db2 = await _seed();
    await boot(t, db2, const Size(1280, 800));
    await shot(t, '14-escritorio');
    // Atajo de teclado: Ctrl+N abre "anotar gasto".
    await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.keyN);
    await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.textContaining('GUARDAR GASTO'), findsOneWidget, reason: 'Ctrl+N debería abrir anotar gasto');
    await finish(t, db2);
  });
}
