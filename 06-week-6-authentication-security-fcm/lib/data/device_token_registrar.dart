import 'package:dio/dio.dart';

import '../domain/repositories/device_token_registrar.dart';

/// Backend adapter responsible only for registering an FCM device token.
class ApiDeviceTokenRegistrar implements DeviceTokenRegistrar {
  const ApiDeviceTokenRegistrar(this._api);

  final Dio _api;

  @override
  Future<void> register({
    required String token,
    required String platform,
  }) async {
    await _api.post<void>(
      '/devices',
      data: {'token': token, 'platform': platform},
    );
  }
}
