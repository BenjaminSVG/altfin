// Flujos de pantalla del balance personal: cargar cuánto dinero tengo, verlo por
// período, cobrar el sueldo y cargar gastos periódicos (por día, semana o mes).
// Con ALTFIN_SCREENSHOTS=1 guarda capturas.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:altfin/data/database.dart';
import 'package:altfin/domain/habit_rule.dart';
import 'package:altfin/features/transactions/add_txn_screen.dart';
import 'package:altfin/main.dart';
import 'package:altfin/state/providers.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 10, 12, 10, 30); // lunes
final _write = Platform.environment['ALTFIN_SCREENSHOTS'] == '1';

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

  Future<AppDatabase> freshDb({int income = 5000000}) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.getSetting('x');
    await saveSettings(db, {
      'onboarded': '1',
      'name': 'Beni',
      'currency': 'PYG',
      'net_income': '$income',
      'profile': 'rocket',
    });
    return db;
  }

  Future<void> boot(WidgetTester t, AppDatabase db) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = phone;
    addTearDown(t.view.reset);
    await t.pumpWidget(RepaintBoundary(
      key: key,
      child: ProviderScope(
        overrides: [dbProvider.overrideWithValue(db), clockProvider.overrideWithValue(() => _now)],
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

  // Espera a que terminen las escrituras reales en la base y se redibuje (pumpAndSettle no sirve con cuadros de texto enfocados).
  Future<void> settle(WidgetTester t) async {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 250)));
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> tapText(WidgetTester t, String text) async {
    final f = find.text(text);
    await t.ensureVisible(f.first);
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(f.first);
    await t.pump(const Duration(milliseconds: 500));
  }

  Future<void> openBalance(WidgetTester t) async {
    await tapText(t, 'Cargá cuánto dinero tenés');
    await settle(t);
  }

  setUpAll(_loadFonts);

  testWidgets('cargar cuánto dinero tengo y verlo subir y bajar con lo que anoto', (t) async {
    final db = await freshDb();
    await boot(t, db);
    expect(find.text('Cargá cuánto dinero tenés'), findsOneWidget);
    await openBalance(t);
    expect(find.text('CARGAR MI DINERO'), findsOneWidget);
    await shot(t, '30-balance-vacio');
    await t.tap(find.text('CARGAR MI DINERO'));
    await t.pump(const Duration(milliseconds: 500));
    await t.enterText(find.byType(TextField), '2000000');
    await t.tap(find.text('Guardar'));
    await settle(t);
    expect(await t.runAsync(() => db.getSetting('opening_balance')), '2000000');
    expect(find.text('DINERO DISPONIBLE'), findsOneWidget);
    expect(find.text('₲ 2.000.000'), findsOneWidget);

    // Un gasto de hoy (después de declarar el dinero) lo baja; un ingreso lo sube.
    await t.runAsync(() => db.addTxn(TxnsCompanion.insert(
        kind: 'expense', amountMinor: 150000, currency: 'PYG', date: _now.add(const Duration(minutes: 5)))));
    await t.pump(const Duration(milliseconds: 600));
    await t.runAsync(() => db.addTxn(TxnsCompanion.insert(
        kind: 'income', amountMinor: 400000, currency: 'PYG', date: _now.add(const Duration(minutes: 6)))));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('₲ 2.250.000'), findsOneWidget);

    // Un gasto anterior al momento declarado ya estaba incluido: no cambia nada.
    await t.runAsync(() => db.addTxn(TxnsCompanion.insert(
        kind: 'expense', amountMinor: 999000, currency: 'PYG', date: _now.subtract(const Duration(days: 1)))));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('₲ 2.250.000'), findsOneWidget);
    await shot(t, '31-balance');

    // Períodos: hoy solo cuenta lo de hoy.
    await t.tap(find.text('Hoy'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Resumen de hoy'), findsOneWidget);
    expect(find.text('-₲ 150.000'), findsOneWidget);
    await t.tap(find.text('Año'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Resumen de este año'), findsOneWidget);
    expect(find.text('-₲ 1.149.000'), findsOneWidget);
    await finish(t, db);
  });

  testWidgets('cobrar el sueldo suma al dinero disponible y no se duplica en el presupuesto', (t) async {
    final db = await freshDb();
    await t.runAsync(() async {
      await saveSettings(db, {'profile': 'none', 'opening_balance': '1000000', 'opening_at': _now.subtract(const Duration(hours: 1)).toIso8601String()});
    });
    await boot(t, db);
    expect(find.text('₲ 1.000.000'), findsOneWidget);
    final before = find.text('PODÉS GASTAR HOY');
    expect(before, findsOneWidget);
    await tapText(t, 'Dinero disponible');
    await settle(t);
    await tapText(t, 'Ya cobré mi sueldo');
    await settle(t);
    await t.drag(find.byType(ListView).last, const Offset(0, 1500)); // volver arriba
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('₲ 6.000.000'), findsOneWidget);
    expect(find.text('Ya cobré mi sueldo'), findsNothing);
    final rows = await t.runAsync(() => db.select(db.txns).get());
    expect(rows!.single.note, 'Sueldo');
    expect(rows.single.kind, 'income');

    // Volver al inicio (sin porcentajes el presupuesto es todo lo que ingresó): el sueldo no se cuenta dos veces.
    await t.tap(find.byType(BackButton));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Te quedan ₲ 5.000.000'), findsOneWidget);
    await finish(t, db);
  });

  testWidgets('gastos periódicos: diario, semanal y mensual se anotan solos', (t) async {
    final db = await freshDb();
    await boot(t, db);
    await t.tap(find.text('Metas'));
    await t.pump(const Duration(milliseconds: 600));
    await tapText(t, 'Gastos periódicos');
    await settle(t);
    expect(find.text('AGREGAR UN GASTO'), findsOneWidget);

    Future<void> add(String freq, String name, String amount, {String? day}) async {
      await t.tap(find.text('+ Nuevo'));
      await settle(t);
      await t.tap(find.text(freq));
      await t.pump(const Duration(milliseconds: 300));
      await t.enterText(find.byType(TextField).at(0), name);
      await t.enterText(find.byType(TextField).at(1), amount);
      await t.pump(const Duration(milliseconds: 300));
      if (day != null) {
        await t.tap(find.text(day));
        await t.pump(const Duration(milliseconds: 300));
      }
      await t.ensureVisible(find.text('GUARDAR'));
      await t.tap(find.text('GUARDAR'));
      await settle(t);
    }

    await add('Cada día', 'Almuerzo', '20000');
    await add('Cada semana', 'Feria', '100000', day: 'V'); // viernes
    await add('Cada mes', 'Internet', '150000');

    final habits = (await t.runAsync(() => db.select(db.habits).get()))!;
    expect(habits.length, 2);
    expect(habits.firstWhere((h) => h.name == 'Almuerzo').weekdays, HabitRule.everyDay);
    expect(habits.firstWhere((h) => h.name == 'Feria').weekdays, HabitRule.bit(5));
    final recs = (await t.runAsync(() => db.select(db.recurrings).get()))!;
    expect(recs.single.name, 'Internet');
    expect(recs.single.amountMinor, 150000);
    expect(recs.single.dayOfMonth, 1);

    // Hoy es lunes: se anotó el almuerzo de hoy y el internet del día 1; la feria (viernes) todavía no.
    final txns = (await t.runAsync(() => db.select(db.txns).get()))!;
    expect(txns.map((x) => x.note).toSet(), {'Almuerzo', 'Internet'});

    // Octubre 2026 tiene 31 días y 5 viernes: 20.000×31 + 100.000×5 + 150.000 = 1.270.000.
    expect(find.text('Cada día'), findsOneWidget);
    expect(find.text('Cada viernes'), findsOneWidget);
    expect(find.text('El día 1 de cada mes'), findsOneWidget);
    expect(find.text('₲ 1.270.000'), findsOneWidget);
    await shot(t, '32-gastos-periodicos');

    // Cambiar el monto de un gasto.
    await t.tap(find.text('Almuerzo').first);
    await t.pump(const Duration(milliseconds: 500));
    await t.enterText(find.byType(TextField), '25000');
    await t.tap(find.text('Guardar'));
    await settle(t);
    expect((await t.runAsync(() => db.select(db.habits).get()))!.firstWhere((h) => h.name == 'Almuerzo').unitPriceMinor, 25000);
    await finish(t, db);
  });

  testWidgets('desde un widget se abre directo el tipo de movimiento que dice', (t) async {
    final db = await freshDb();
    await boot(t, db);
    final ctx = t.element(find.byType(Scaffold).first);
    Navigator.of(ctx).push(MaterialPageRoute<void>(builder: (_) => const AddTxnScreen(initialKind: 'income', fromWidget: true)));
    await settle(t);
    expect(find.text('GUARDAR INGRESO  ·  +10 XP'), findsOneWidget);
    expect(find.text('GUARDAR GASTO  ·  +10 XP'), findsNothing);
    await finish(t, db);
  });
}
