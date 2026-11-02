import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/device_token_registrar.dart';
import '../data/token_store.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/device_token_registrar.dart';
import '../domain/repositories/token_store.dart';
import '../data/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return SecureTokenStore();
});

final apiClientProvider = Provider<Dio>((ref) {
  return buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
  );
});

final deviceTokenRegistrarProvider = Provider<DeviceTokenRegistrar>((ref) {
  return ApiDeviceTokenRegistrar(ref.watch(apiClientProvider));
});
