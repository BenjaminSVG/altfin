import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

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
