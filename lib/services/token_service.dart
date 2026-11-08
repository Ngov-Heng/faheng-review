import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

String get _secret =>
    Platform.environment['JWT_SECRET'] ?? 'dev-only-secret-change-me';

/// Creates a signed login token for [userId] that expires in 7 days.
String createToken(String userId) {
  return JWT({'sub': userId}).sign(
    SecretKey(_secret),
    expiresIn: const Duration(days: 7),
  );
}

/// Returns the user id inside a valid token, or null if it is bad or expired.
String? verifyToken(String token) {
  try {
    final jwt = JWT.verify(token, SecretKey(_secret));
    final payload = jwt.payload;
    if (payload is Map<String, dynamic>) return payload['sub'] as String?;
    return null;
  } catch (_) {
    return null;
  }
}
