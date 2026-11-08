import 'package:faheng_api/services/pricing_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

double _dollars(int cents) => cents / 100;

/// Builds the cart screen data for [userId] with live prices and totals.
Future<Map<String, dynamic>> buildCartView(Db db, ObjectId userId) async {
  final cart = await db.collection('carts').findOne(where.id(userId));
  final saved = (cart?['items'] as List?) ?? const [];

  final ids = [
    for (final item in saved) (item as Map)['productId'] as ObjectId,
  ];
  final products = ids.isEmpty
      ? <Map<String, dynamic>>[]
      : await db
            .collection('products')
            .find(where.oneFrom('_id', ids).eq('isActive', true))
            .toList();
  final byId = {for (final p in products) (p['_id'] as ObjectId).oid: p};

  final items = <Map<String, dynamic>>[];
  final lineCents = <int>[];
  var totalKg = 0.0;

  for (final entry in saved) {
    final item = entry as Map;
    final productId = (item['productId'] as ObjectId).oid;
    final product = byId[productId];
    if (product == null) continue;

    final kg = item['quantityKg'] as num;
    final unitCents = toCents(product['pricePerKg'] as num);
    final line = (unitCents * kg).round();

    lineCents.add(line);
    totalKg += kg;
    items.add({
      'productId': productId,
      'name': product['name'],
      'image': product['image'],
      'pricePerKg': _dollars(unitCents),
      'quantityKg': kg,
      'lineTotal': _dollars(line),
    });
  }

  final totals = calculateTotals(lineCents: lineCents, totalKg: totalKg);
  return {
    'items': items,
    'totalKg': totalKg,
    'subtotal': _dollars(totals.subtotalCents),
    'discount': _dollars(totals.discountCents),
    'total': _dollars(totals.totalCents),
  };
}
