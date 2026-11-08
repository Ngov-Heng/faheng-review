import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  ObjectId objectId;
  try {
    objectId = ObjectId.parse(id);
  } catch (_) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid product id'},
    );
  }

  final db = context.read<Db>();
  final doc = await db
      .collection('products')
      .findOne(where.id(objectId).eq('isActive', true));

  if (doc == null) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Product not found'},
    );
  }

  return Response.json(
    body: {...doc, '_id': (doc['_id'] as ObjectId).oid},
  );
}
