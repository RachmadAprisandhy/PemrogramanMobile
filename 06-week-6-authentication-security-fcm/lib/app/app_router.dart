import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../features/announcements/presentation/announcement_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/home/presentation/home_page.dart';
import '../routes.dart';

GoRouter createAppRouter({
  required Listenable refreshListenable,
  required bool? Function() readAuthenticated,
}) {
  return GoRouter(
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authenticated = readAuthenticated();
      if (authenticated == null) return null;

      final goingToLogin = state.matchedLocation == AppRoutes.login;
      if (!authenticated && !goingToLogin) {
        return Uri(
          path: AppRoutes.login,
          queryParameters: {'from': state.uri.toString()},
        ).toString();
      }

      if (authenticated && goingToLogin) {
        final destination = state.uri.queryParameters['from'];
        if (destination != null &&
            destination.startsWith('/') &&
            !destination.startsWith('//')) {
          return destination;
        }
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcementPattern,
        builder: (context, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
}
