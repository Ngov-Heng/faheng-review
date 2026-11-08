import 'package:dart_frog/dart_frog.dart';
import 'package:faheng_api/services/password_service.dart';
import 'package:faheng_api/services/token_service.dart';
import 'package:faheng_api/services/validators.dart';
import 'package:mongo_dart/mongo_dart.dart';

Response _error(int status, String message) =>
    Response.json(statusCode: status, body: {'error': message});

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

  final identifier = body['identifier'];
  final password = body['password'];
  if (identifier is! String ||
      identifier.trim().isEmpty ||
      password is! String ||
      password.isEmpty) {
    return _error(400, 'identifier and password are required');
  }

  final trimmed = identifier.trim();
  final query = trimmed.contains('@')
      ? {'email': normalizeEmail(trimmed)}
      : {'phone': normalizePhone(trimmed)};

  final user = await context.read<Db>().collection('users').findOne(query);
  if (user == null ||
      !verifyPassword(password, user['passwordHash'] as String)) {
    return _error(401, 'Invalid credentials');
  }

  final id = (user['_id'] as ObjectId).oid;
  return Response.json(
    body: {
      'token': createToken(id),
      'user': {
        'id': id,
        'name': user['name'],
        if (user['email'] != null) 'email': user['email'],
        if (user['phone'] != null) 'phone': user['phone'],
      },
    },
  );
}
