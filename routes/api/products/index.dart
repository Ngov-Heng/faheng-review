import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final params = context.request.uri.queryParameters;
  final category = params['category'];
  final q = params['q']?.trim();
  final featured = params['featured'] == 'true';
  final sort = params['sort'] ?? 'name';
  final page = int.tryParse(params['page'] ?? '') ?? 1;
  final limit = int.tryParse(params['limit'] ?? '') ?? 10;

  const allowedSorts = ['name', 'price_asc', 'price_desc'];
  if (page < 1 || limit < 1 || limit > 50 || !allowedSorts.contains(sort)) {
    return Response.json(
      statusCode: 400,
      body: {
        'error':
            'page must be 1 or more, limit 1 to 50, '
            'sort must be name, price_asc or price_desc',
      },
    );
  }

  final db = context.read<Db>();
  final collection = db.collection('products');

  final selector = where.eq('isActive', true);
  if (category != null && category.isNotEmpty) {
    selector.eq('category', category);
  }
  if (q != null && q.isNotEmpty) {
    selector.match('name', RegExp.escape(q), caseInsensitive: true);
  }
  if (featured) {
    selector.eq('isFeatured', true);
  }

  final total = await collection.count(selector);

  switch (sort) {
    case 'price_asc':
      selector.sortBy('pricePerKg');
    case 'price_desc':
      selector.sortBy('pricePerKg', descending: true);
    default:
      selector.sortBy('name');
  }
  selector.skip((page - 1) * limit).limit(limit);
  final docs = await collection.find(selector).toList();

  final items = docs.map((doc) {
    return {...doc, '_id': (doc['_id'] as ObjectId).oid};
  }).toList();

  return Response.json(
    body: {'items': items, 'total': total, 'page': page, 'limit': limit},
  );
}
