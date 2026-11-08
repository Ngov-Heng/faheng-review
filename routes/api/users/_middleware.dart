import 'package:dart_frog/dart_frog.dart';
import 'package:faheng_api/middleware/auth_guard.dart';

Handler middleware(Handler handler) => authGuard(handler);
