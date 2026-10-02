import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart' show AndroidAuthMessages;

/// Desbloqueo con huella, rostro o Windows Hello. Se separa en una interfaz
/// para poder probarlo sin un dispositivo real.
abstract class BiometricService {
  /// ¿Hay algo registrado en el equipo (una huella, un rostro, Windows Hello)?
  Future<bool> isAvailable();

  /// Muestra el aviso del sistema. true = la persona se identificó.
  Future<bool> authenticate(String reason);
}

class LocalBiometricService implements BiometricService {
  LocalBiometricService([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  bool get _supported => !kIsWeb && (Platform.isAndroid || Platform.isWindows);

  @override
  Future<bool> isAvailable() async {
    if (!_supported) return false;
    try {
      if (!await _auth.isDeviceSupported()) return false;
      if (Platform.isWindows) return true; // Windows Hello: el sistema decide al pedirlo.
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    } on LocalAuthException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    if (!_supported) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Desbloquear AltFin',
            signInHint: 'Tocá el sensor',
            cancelButton: 'Usar PIN o contraseña',
          ),
        ],
      );
    } on PlatformException {
      return false;
    } on LocalAuthException {
      return false;
    }
  }
}

final biometricProvider = Provider<BiometricService>((ref) => LocalBiometricService());
