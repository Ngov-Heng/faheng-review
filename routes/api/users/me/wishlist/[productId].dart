import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Response _error(int status, String message) =>
    Response.json(statusCode: status, body: {'error': message});

Future<Response> onRequest(RequestContext context, String productId) async {
  final ObjectId pid;
  try {
    pid = ObjectId.fromHexString(productId);
  } catch (_) {
    return _error(400, 'Invalid product id');
  }

  final db = context.read<Db>();
  final user = context.read<Map<String, dynamic>>();
  final userId = user['_id'] as ObjectId;

  switch (context.request.method) {
    case HttpMethod.put:
      final product = await db
          .collection('products')
          .findOne(where.id(pid).eq('isActive', true));
      if (product == null) return _error(404, 'Product not found');

      await db
          .collection('users')
          .updateOne(where.id(userId), modify.addToSet('wishlist', pid));
      return Response.json(body: {'productId': pid.oid, 'wishlisted': true});
    case HttpMethod.delete:
      await db
          .collection('users')
          .updateOne(where.id(userId), modify.pull('wishlist', pid));
      return Response.json(body: {'productId': pid.oid, 'wishlisted': false});
    case HttpMethod.get:
    case HttpMethod.post:
    case HttpMethod.patch:
    case HttpMethod.head:
    case HttpMethod.options:
      return Response(statusCode: 405);
  }
}
