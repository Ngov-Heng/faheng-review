import 'package:dart_frog/dart_frog.dart';
import 'package:faheng_api/services/password_service.dart';
import 'package:faheng_api/services/validators.dart';
import 'package:mongo_dart/mongo_dart.dart';

Response _error(int status, String message) =>
    Response.json(statusCode: status, body: {'error': message});

String? _text(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  Object? body;
  try {
    body = await context.request.json();
  } catch (_) {
    return _error(400, 'Body must be valid JSON');
  }
  if (body is! Map<String, dynamic>) {
    return _error(400, 'Body must be a JSON object');
  }

  final name = _text(body['name']);
  final emailRaw = _text(body['email']);
  final phoneRaw = _text(body['phone']);
  final password = body['password'];

  if (name == null) return _error(400, 'name is required');
  if (password is! String || password.length < 8) {
    return _error(400, 'password must be at least 8 characters');
  }
  if (emailRaw == null && phoneRaw == null) {
    return _error(400, 'email or phone is required');
  }

  final email = emailRaw == null ? null : normalizeEmail(emailRaw);
  final phone = phoneRaw == null ? null : normalizePhone(phoneRaw);
  if (email != null && !isValidEmail(email)) {
    return _error(400, 'email is not valid');
  }
  if (phone != null && !isValidPhone(phone)) {
    return _error(400, 'phone is not valid');
  }

  final users = context.read<Db>().collection('users');
  final existing = await users.findOne({
    r'$or': [
      if (email != null) {'email': email},
      if (phone != null) {'phone': phone},
    ],
  });
  if (existing != null) {
    return _error(409, 'An account with this email or phone already exists');
  }

  final id = ObjectId();
  final result = await users.insertOne({
    '_id': id,
    'name': name,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
    'passwordHash': hashPassword(password),
    'createdAt': DateTime.now().toUtc(),
  });
  if (!result.isSuccess) {
    return _error(409, 'An account with this email or phone already exists');
  }

  return Response.json(
    statusCode: 201,
    body: {
      'id': id.oid,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    },
  );
}
