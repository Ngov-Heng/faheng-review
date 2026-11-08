import 'package:dart_frog/dart_frog.dart';
import 'package:faheng_api/services/token_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

Response _unauthorized() =>
    Response.json(statusCode: 401, body: {'error': 'Unauthorized'});

/// Checks the login token, loads the user and gives it to the routes below.
///
/// Routes read the user with `context.read<Map<String, dynamic>>()`.
Handler authGuard(Handler handler) {
  return (context) async {
    final header = context.request.headers['authorization'];
    if (header == null || !header.startsWith('Bearer ')) {
      return _unauthorized();
    }

    final userId = verifyToken(header.substring(7).trim());
    if (userId == null) return _unauthorized();

    final ObjectId id;
    try {
      id = ObjectId.fromHexString(userId);
    } catch (_) {
      return _unauthorized();
    }

    final user = await context
        .read<Db>()
        .collection('users')
        .findOne(where.id(id));
    if (user == null) return _unauthorized();

    return handler
        .use(provider<Map<String, dynamic>>((_) => user))
        .call(context);
  };
}
