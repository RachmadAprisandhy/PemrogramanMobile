class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcementPattern = '/pengumuman/:id';

  static String announcement(String id) => '/pengumuman/$id';

  static String routeFromMessage(Map<String, dynamic> data) {
    final route = data['route'];

    if (route is String &&
        route.startsWith('/') &&
        !route.startsWith('//')) {
      return route;
    }

    return home;
  }
}