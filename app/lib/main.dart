import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/lock/lock_gate.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/app_shell.dart';
import 'services/notification_service.dart';
import 'state/providers.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const ProviderScope(child: AltFinApp()));
}

class AltFinApp extends ConsumerWidget {
  const AltFinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final dark = settings.value?.dark ?? false;
    return MaterialApp(
      title: 'AltFin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: settings.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
        data: (s) => s.onboarded ? const LockGate(child: AppShell()) : const OnboardingScreen(),
      ),
    );
  }
}
