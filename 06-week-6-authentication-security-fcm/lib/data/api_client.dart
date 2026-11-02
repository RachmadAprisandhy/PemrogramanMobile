import 'package:dio/dio.dart';

import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/token_store.dart';

Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final request = error.requestOptions;
        if (error.response?.statusCode != 401 ||
            request.extra['authRetry'] == true) {
          handler.next(error);
          return;
        }

        final refresh = await store.readRefresh();
        if (refresh == null) {
          handler.next(error);
          return;
        }

        try {
          final renewed = await auth.refresh(refresh);
          await store.save(access: renewed, refresh: refresh);

          request
            ..headers['Authorization'] = 'Bearer $renewed'
            ..extra['authRetry'] = true;

          final response = await dio.fetch<Object?>(request);
          handler.resolve(response);
        } catch (_) {
          await store.clear();
          handler.next(error);
        }
      },
    ),
  );

  return dio;
}
