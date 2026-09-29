import 'package:web_dex/router/routes.dart';

abstract class BaseRouteParser {
  AppRoutePath getRoutePath(Uri uri);
}
