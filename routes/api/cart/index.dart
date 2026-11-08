import 'package:dart_frog/dart_frog.dart';
import 'package:faheng_api/services/cart_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final user = context.read<Map<String, dynamic>>();
  final userId = user['_id'] as ObjectId;
  final cart = await buildCartView(context.read<Db>(), userId);
  return Response.json(body: cart);
}
