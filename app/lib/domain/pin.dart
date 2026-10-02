import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Tipo de bloqueo de la app: PIN de 4 dígitos o contraseña.
enum LockKind {
  pin,
  password;

  static LockKind fromId(String? id) => id == 'password' ? LockKind.password : LockKind.pin;

  String get id => name;

  String get label => this == LockKind.pin ? 'PIN' : 'contraseña';
}

/// PIN de bloqueo. Nunca se guarda el PIN: solo su hash con sal.
class PinLock {
  const PinLock._();

  static const length = 4;

  static bool isValidFormat(String pin) => RegExp(r'^\d{4}$').hasMatch(pin);

  static String newSalt([Random? rng]) {
    final r = rng ?? Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  static String hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  static bool verify(String pin, String salt, String expectedHash) =>
      isValidFormat(pin) && hash(pin, salt) == expectedHash;
}

/// Contraseña de bloqueo (letras, números, símbolos). Igual que el PIN: solo se
/// guarda su hash con sal, en los mismos ajustes.
class PasswordLock {
  const PasswordLock._();

  static const minLength = 6;
  static const maxLength = 64;

  /// Entre 6 y 64 caracteres y no solo espacios.
  static bool isValidFormat(String password) =>
      password.length >= minLength && password.length <= maxLength && password.trim().isNotEmpty;

  static bool verify(String password, String salt, String expectedHash) =>
      expectedHash.isNotEmpty && PinLock.hash(password, salt) == expectedHash;
}

/// Verificación común para cualquiera de los dos tipos de bloqueo.
class AppLock {
  const AppLock._();

  static bool isValidFormat(LockKind kind, String secret) =>
      kind == LockKind.pin ? PinLock.isValidFormat(secret) : PasswordLock.isValidFormat(secret);

  static bool verify(LockKind kind, String secret, String salt, String expectedHash) =>
      kind == LockKind.pin ? PinLock.verify(secret, salt, expectedHash) : PasswordLock.verify(secret, salt, expectedHash);

  /// Segundos de espera tras [failedAttempts] intentos seguidos mal: a partir
  /// del 5.º intento, 30 s; del 8.º, 2 min; del 10.º, 10 min.
  static int lockoutSeconds(int failedAttempts) {
    if (failedAttempts >= 10) return 600;
    if (failedAttempts >= 8) return 120;
    if (failedAttempts >= 5) return 30;
    return 0;
  }
}
