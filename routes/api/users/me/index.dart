import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final user = context.read<Map<String, dynamic>>();
  final createdAt = user['createdAt'];

  return Response.json(
    body: {
      'id': (user['_id'] as ObjectId).oid,
      'name': user['name'],
      if (user['email'] != null) 'email': user['email'],
      if (user['phone'] != null) 'phone': user['phone'],
      if (createdAt is DateTime) 'createdAt': createdAt.toIso8601String(),
    },
  );
}
