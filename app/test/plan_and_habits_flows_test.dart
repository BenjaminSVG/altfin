// Flujos de pantalla: omitir sueldo/plan, plan personalizado o sin porcentaje,
// y gastos repetitivos (autobús). Con ALTFIN_SCREENSHOTS=1 guarda capturas.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:altfin/data/database.dart';
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

Future<String?> _get(WidgetTester t, AppDatabase db, String key) async =>
    await t.runAsync<String?>(() => db.getSetting(key));

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

  Future<AppDatabase> freshDb({bool onboarded = false, int income = 5000000, String profile = 'rocket'}) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.getSetting('x');
    if (onboarded) {
      await saveSettings(db, {
        'onboarded': '1',
        'name': 'Beni',
        'currency': 'PYG',
        'net_income': '$income',
        'profile': profile,
      });
    }
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

  Future<void> tapText(WidgetTester t, String text) async {
    final f = find.text(text);
    await t.ensureVisible(f.first);
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(f.first);
    await t.pump(const Duration(milliseconds: 500));
  }

  setUpAll(_loadFonts);

  testWidgets('se puede omitir el sueldo en el onboarding (ej. desempleo)', (t) async {
    final db = await freshDb();
    await boot(t, db);
    await t.tap(find.text('EMPEZAR'));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('OMITIR POR AHORA'), findsOneWidget);
    await tapText(t, 'OMITIR POR AHORA');
    await t.pump(const Duration(milliseconds: 800));
    expect(await t.runAsync(() => db.getSetting('onboarded')), '1');
    expect(await t.runAsync(() => db.getSetting('net_income')), '0');
    expect(await t.runAsync(() => db.getSetting('profile')), 'none');
    // Entra a la app sin sueldo y sin errores.
    expect(find.text('SIN INGRESOS CARGADOS'), findsOneWidget);
    expect(find.textContaining('Sin sueldo cargado'), findsOneWidget);
    await shot(t, '19-sin-sueldo');
    await finish(t, db);
  });

  testWidgets('con sueldo, se puede elegir "Sin porcentaje"', (t) async {
    final db = await freshDb();
    await boot(t, db);
    await t.tap(find.text('EMPEZAR'));
    await t.pump(const Duration(milliseconds: 600));
    await t.enterText(find.byType(TextField).first, '5000000');
    await t.pump();
    await tapText(t, 'CONTINUAR');
    expect(find.text('Personalizado'), findsOneWidget);
    expect(find.text('Sin porcentaje'), findsOneWidget);
    expect(find.text('OMITIR'), findsOneWidget);
    await tapText(t, 'Sin porcentaje');
    await shot(t, '20-perfil-opciones');
    await tapText(t, 'CONTINUAR SIN PORCENTAJE');
    await t.pump(const Duration(milliseconds: 800));
    expect(await t.runAsync(() => db.getSetting('profile')), 'none');
    expect(await t.runAsync(() => db.getSetting('net_income')), '5000000');
    // Sin plan, igual muestra cuánto puede gastar hoy.
    expect(find.text('PODÉS GASTAR HOY'), findsOneWidget);
    expect(find.textContaining('Sin porcentajes'), findsOneWidget);
    await finish(t, db);
  });

  testWidgets('el botón Omitir del paso de porcentaje también funciona', (t) async {
    final db = await freshDb();
    await boot(t, db);
    await t.tap(find.text('EMPEZAR'));
    await t.pump(const Duration(milliseconds: 600));
    await t.enterText(find.byType(TextField).first, '3000000');
    await t.pump();
    await tapText(t, 'CONTINUAR');
    await tapText(t, 'OMITIR');
    await t.pump(const Duration(milliseconds: 800));
    expect(await t.runAsync(() => db.getSetting('profile')), 'none');
    expect(await t.runAsync(() => db.getSetting('onboarded')), '1');
    await finish(t, db);
  });

  testWidgets('plan personalizado: porcentajes que suman 100 y ahorro editable', (t) async {
    final db = await freshDb();
    await boot(t, db);
    await t.tap(find.text('EMPEZAR'));
    await t.pump(const Duration(milliseconds: 600));
    await t.enterText(find.byType(TextField).first, '5000000');
    await t.pump();
    await tapText(t, 'CONTINUAR');
    await tapText(t, 'Personalizado');
    expect(find.byType(Slider), findsNWidgets(2));
    // Subo "Necesidades" arrastrando su slider: el ahorro es lo que sobra.
    await t.drag(find.byType(Slider).first, const Offset(60, 0));
    await t.pump(const Duration(milliseconds: 300));
    await shot(t, '21-plan-personalizado');
    await tapText(t, 'USAR MI PLAN PERSONALIZADO');
    await t.pump(const Duration(milliseconds: 800));
    expect(await t.runAsync(() => db.getSetting('profile')), 'custom');
    final n = int.parse((await _get(t, db, 'pct_needs'))!);
    final w = int.parse((await _get(t, db, 'pct_wants'))!);
    final s = int.parse((await _get(t, db, 'pct_savings'))!);
    expect(n + w + s, 100);
    expect(n, greaterThan(40), reason: 'el slider de necesidades subió');
    await finish(t, db);
  });

  testWidgets('autobús: veces al día, precio y días; se anota solo', (t) async {
    final db = await freshDb(onboarded: true);
    await boot(t, db);
    await t.tap(find.text('Finn').last);
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.byIcon(Icons.settings_rounded));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await tapText(t, 'Autobús y gastos repetitivos');
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await tapText(t, 'AGREGAR AUTOBÚS');
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    // El formulario trae autobús: 2 veces al día, lunes a viernes.
    expect(find.text('Nuevo gasto repetitivo'), findsOneWidget);
    await t.enterText(find.widgetWithText(TextField, 'Nombre'), 'Autobús al trabajo');
    await t.enterText(find.byType(TextField).at(1), '2300');
    await t.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('por día'), findsOneWidget);
    await shot(t, '22-autobus-formulario');
    await t.tap(find.text('GUARDAR'));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    final habits = await t.runAsync(() => db.select(db.habits).get());
    expect(habits!.length, 1);
    expect(habits.single.timesPerDay, 2);
    expect(habits.single.unitPriceMinor, 2300);
    expect(habits.single.weekdays, 31);
    // Hoy es lunes: ya se anotó el gasto del día (2 × ₲ 2.300 = ₲ 4.600).
    final txs = await t.runAsync(() => db.allTxns());
    expect(txs!.length, 1);
    expect(txs.single.amountMinor, 4600);
    expect(txs.single.note, 'Autobús al trabajo ×2');
    expect(find.text('Autobús al trabajo'), findsOneWidget);
    await shot(t, '23-autobus-lista');
    await finish(t, db);
  });

  testWidgets('fondo de emergencia: calcula y crea la meta', (t) async {
    final db = await freshDb(onboarded: true);
    await boot(t, db);
    await t.tap(find.text('Metas'));
    await t.pump(const Duration(milliseconds: 600));
    await tapText(t, 'Fondo de emergencia');
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await t.enterText(find.byType(TextField).first, '2000000');
    await t.pump();
    await tapText(t, '6 meses');
    expect(find.textContaining('12.000.000'), findsOneWidget);
    await shot(t, '25-fondo-emergencia');
    await tapText(t, 'CREAR META');
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    final goals = await t.runAsync(() => db.select(db.goals).get());
    expect(goals!.single.name, 'Fondo de emergencia');
    expect(goals.single.targetMinor, 12000000);
    await finish(t, db);
  });

  testWidgets('patrimonio neto: cargar un activo y una deuda', (t) async {
    final db = await freshDb(onboarded: true);
    await boot(t, db);
    await t.tap(find.text('Metas'));
    await t.pump(const Duration(milliseconds: 600));
    await tapText(t, 'Patrimonio neto');
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    for (final row in [(false, 'Cuenta', '5000000'), (true, 'Préstamo', '1500000')]) {
      await t.tap(find.text('AGREGAR'));
      await t.pumpAndSettle(const Duration(milliseconds: 100));
      if (row.$1 == false) {
        // por defecto es "Tengo"
      } else {
        await t.tap(find.text('Debo'));
        await t.pump();
      }
      await t.enterText(find.byType(TextField).at(0), row.$2);
      await t.enterText(find.byType(TextField).at(1), row.$3);
      await t.pump();
      await t.tap(find.text('Guardar'));
      await t.pumpAndSettle(const Duration(milliseconds: 100));
    }
    expect(find.text('₲ 3.500.000'), findsOneWidget);
    await shot(t, '26-patrimonio');
    final snaps = await t.runAsync(() => db.select(db.netSnapshots).get());
    expect(snaps!.single.month, '2026-10');
    expect(snaps.single.netMinor, 3500000);
    await finish(t, db);
  });

  testWidgets('gastos compartidos: pago yo, divido entre 2 amigos y anota mi parte', (t) async {
    final db = await freshDb(onboarded: true);
    final ana = await t.runAsync(() => db.addFriend('Ana'));
    final leo = await t.runAsync(() => db.addFriend('Leo'));
    await boot(t, db);
    await t.tap(find.text('Metas'));
    await t.pump(const Duration(milliseconds: 600));
    await tapText(t, 'Gastos compartidos');
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await t.tap(find.text('DIVIDIR GASTO'));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await t.enterText(find.byType(TextField).at(0), 'Cena');
    await t.enterText(find.byType(TextField).at(1), '90000');
    await t.pump();
    expect(find.text('Cada uno: ₲ 30.000'), findsOneWidget);
    await shot(t, '27-gastos-compartidos');
    await t.tap(find.text('Guardar'));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    final entries = await t.runAsync(() => db.select(db.shareEntries).get());
    expect(entries!.length, 2);
    expect(entries.map((e) => e.friendId).toSet(), {ana, leo});
    expect(entries.every((e) => e.amountMinor == 30000), isTrue);
    final txs = await t.runAsync(() => db.allTxns());
    expect(txs!.single.amountMinor, 30000);
    expect(find.textContaining('Ana te debe ₲ 30.000'), findsOneWidget);
    await finish(t, db);
  });

  testWidgets('en Ajustes se puede quitar el sueldo y el porcentaje', (t) async {
    final db = await freshDb(onboarded: true);
    await boot(t, db);
    expect(find.text('PODÉS GASTAR HOY'), findsOneWidget);
    await t.tap(find.text('Finn').last);
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.byIcon(Icons.settings_rounded));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await tapText(t, 'Sueldo y plan de ahorro');
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await shot(t, '24-sueldo-y-plan');
    // El botón está al final de una lista larga: se desliza hasta abajo.
    await t.drag(find.byType(ListView).last, const Offset(0, -2500));
    await t.pump(const Duration(milliseconds: 500));
    await tapText(t, 'QUITAR SUELDO Y PORCENTAJES');
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(await t.runAsync(() => db.getSetting('net_income')), '0');
    expect(await t.runAsync(() => db.getSetting('profile')), 'none');
    await finish(t, db);
  });
}
