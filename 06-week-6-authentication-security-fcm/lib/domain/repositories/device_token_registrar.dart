abstract interface class DeviceTokenRegistrar {
  Future<void> register({required String token, required String platform});
}
