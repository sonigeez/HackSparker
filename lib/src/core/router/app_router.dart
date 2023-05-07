import 'package:go_router/go_router.dart';
import 'package:hacksparker/src/core/router/routes.dart';
import 'package:hacksparker/src/home/ui/home_page.dart';

class AppRouter {
  static final GoRouter goRouter = GoRouter(routes: [
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => HomePage(),
    ),
  ]);
}
