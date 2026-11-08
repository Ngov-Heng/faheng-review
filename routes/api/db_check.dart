// check whehter the connection from middleware to MongoDB is successed.

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<Db>();
  final result = await db.pingCommand();
  return Response.json(
    body: {'database': 'connected', 'ok': result['ok']},
  );
}
