import 'package:flutter_test/flutter_test.dart';

import '../lib/data/auth_repository.dart';
import '../lib/routes.dart';

void main() {
  test('payload FCM membuka route pengumuman yang benar', () {
    final route = AppRoutes.routeFromMessage({
      'route': '/pengumuman/3',
      'id': '3',
    });

    expect(route, '/pengumuman/3');
  });

  test('route kosong atau tidak aman kembali ke home', () {
    expect(AppRoutes.routeFromMessage({}), AppRoutes.home);
    expect(
      AppRoutes.routeFromMessage({'route': '//alamat-lain'}),
      AppRoutes.home,
    );
  });

  test('refresh token menghasilkan access token baru', () async {
    final repository = AuthRepository();

    final renewed = await repository.refresh('mock-refresh');

    expect(renewed, startsWith('mock-access-renewed-'));
  });

  test('refresh gagal jika refresh token kosong', () async {
    final repository = AuthRepository();

    await expectLater(
      repository.refresh(''),
      throwsA(isA<Exception>()),
    );
  });
}