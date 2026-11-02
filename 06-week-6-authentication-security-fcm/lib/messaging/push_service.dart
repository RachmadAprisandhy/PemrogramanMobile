import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/repositories/device_token_registrar.dart';
import '../providers/app_dependencies.dart';
import '../routes.dart';
import 'local_notification_service.dart';

const _announcementsTopic = 'pengumuman-kampus';

/// Background isolate entry point. It cannot access UI or Riverpod app state.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

final pushServiceProvider = Provider.family<PushService, GoRouter>((
  ref,
  router,
) {
  final service = PushService(
    router: router,
    tokenRegistrar: ref.watch(deviceTokenRegistrarProvider),
  );
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

/// Coordinates Firebase Messaging events and delegates notification display
/// and device-token registration to their focused adapters.
class PushService {
  PushService({
    required this.router,
    required this.tokenRegistrar,
    FirebaseMessaging? messaging,
    LocalNotificationService? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications = localNotifications ?? LocalNotificationService();

  final GoRouter router;
  final DeviceTokenRegistrar tokenRegistrar;
  final FirebaseMessaging _messaging;
  final LocalNotificationService _localNotifications;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _localNotifications.initialize(onNotificationTap: _navigateToRoute);
    await requestPermission();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _navigateFromData(message.data),
    );

    // Keep these APIs because this exercise's push-service prompt requires them.
    // ignore: deprecated_member_use
    _tokenSubscription = _messaging.onTokenRefresh.listen(
      (token) => unawaited(_registerTokenSafely(token)),
      onError: (Object _) {
        debugPrint('Gagal menerima pembaruan token notifikasi.');
      },
    );

    // ignore: deprecated_member_use
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerTokenSafely(token);
    }

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromData(initialMessage.data);
    }

    _navigateToRoute(await _localNotifications.getLaunchRoute());

    try {
      await subscribeToAnnouncements();
    } on FirebaseException {
      debugPrint('Gagal berlangganan pengumuman kampus.');
    }

    _initialized = true;
  }

  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _localNotifications.requestPermission();
    return settings;
  }

  Future<void> subscribeToAnnouncements() =>
      _messaging.subscribeToTopic(_announcementsTopic);

  Future<void> unsubscribeFromAnnouncements() =>
      _messaging.unsubscribeFromTopic(_announcementsTopic);

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();
    _foregroundSubscription = null;
    _openedSubscription = null;
    _tokenSubscription = null;
    _initialized = false;
  }

  Future<void> _registerTokenSafely(String token) async {
    try {
      await tokenRegistrar.register(token: token, platform: _platformName);
    } catch (_) {
      // Never log the token, request body, or authorization header.
      debugPrint('Gagal mendaftarkan perangkat ke server.');
    }
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? _stringValue(message.data['title']);
    final body =
        message.notification?.body ?? _stringValue(message.data['body']);
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      route: _stringValue(message.data['route']),
    );
  }

  void _navigateFromData(Map<String, dynamic> data) {
    router.go(AppRoutes.routeFromMessage(data));
  }

  void _navigateToRoute(String? route) {
    if (route == null ||
        route.isEmpty ||
        !route.startsWith('/') ||
        route.startsWith('//')) {
      return;
    }

    router.go(route);
  }

  String? _stringValue(Object? value) => value is String ? value : null;
}
