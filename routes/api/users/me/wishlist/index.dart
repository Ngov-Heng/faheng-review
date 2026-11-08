import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final user = context.read<Map<String, dynamic>>();
  final ids = (user['wishlist'] as List?)?.cast<ObjectId>() ?? <ObjectId>[];
  if (ids.isEmpty) {
    return Response.json(
      body: {'items': <Map<String, dynamic>>[], 'count': 0},
    );
  }

  final products = await context
      .read<Db>()
      .collection('products')
      .find(where.oneFrom('_id', ids).eq('isActive', true))
      .toList();

  final items = products.map((p) {
    final item = Map<String, dynamic>.from(p)..remove('_id');
    item['id'] = (p['_id'] as ObjectId).oid;
    return item;
  }).toList();

  return Response.json(body: {'items': items, 'count': items.length});
}
