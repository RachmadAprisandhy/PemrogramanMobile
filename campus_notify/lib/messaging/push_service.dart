import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

const _announcementsTopic = 'pengumuman-kampus';
const _androidChannelId = 'campus_announcements';
const _androidChannelName = 'Pengumuman kampus';

/// Background isolate entry point. It cannot access BuildContext, GoRouter,
/// Riverpod providers, or app state owned by the foreground isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // FCM displays notification-payload messages while the app is backgrounded.
  // Handle data-only background work here only; never access UI state.
  // Do not log FCM tokens or credentials.
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
    api: ref.watch(apiClientProvider),
  );
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

class PushService {
  PushService({
    required this.router,
    required this.api,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final GoRouter router;
  final Dio api;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;
  bool _initialized = false;

  /// Call after Firebase.initializeApp() and once GoRouter is ready.
  Future<void> initialize() async {
    if (_initialized) return;

    await _initializeLocalNotifications();
    await requestPermission();

    // Install listeners before reading the initial message to avoid missing taps.
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _navigateFromData(message.data),
    );
    // Prompt compatibility: firebase_messaging 17 marks this API deprecated.
    // ignore: deprecated_member_use
    _tokenSubscription = _messaging.onTokenRefresh.listen(
      (token) => unawaited(_registerTokenSafely(token)),
      onError: (Object _) =>
          debugPrint('Gagal menerima pembaruan token notifikasi.'),
    );

    // Prompt compatibility: firebase_messaging 17 marks this API deprecated.
    // ignore: deprecated_member_use
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerTokenSafely(token);
    }

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromData(initialMessage.data);
    }

    // A local notification created while foregrounded can also launch the app.
    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _navigateToRoute(launchDetails?.notificationResponse?.payload);
    }

    try {
      await subscribeToAnnouncements();
    } on FirebaseException {
      debugPrint('Gagal berlangganan pengumuman kampus.');
    }

    _initialized = true;
  }

  /// iOS: asks for Apple notification authorization through FCM.
  /// Android 13+: FCM requests POST_NOTIFICATIONS at runtime. The manifest must
  /// declare that permission; Android 12 and earlier do not show this prompt.
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Android 13+: explicitly request the local-notification permission too.
    // It is the same OS permission, so this does not create a second permission.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
    }

    // iOS: FCM requestPermission above is the permission prompt. The Darwin
    // local-notification presentation below does not request it a second time.
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

  Future<void> _initializeLocalNotifications() async {
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        _navigateToRoute(response.payload);
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'Informasi dan pengumuman kampus',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _registerTokenSafely(String token) async {
    try {
      await api.post<void>(
        '/devices',
        data: {'token': token, 'platform': _platformName},
      );
    } on DioException catch (error) {
      // Never print tokens, authorization headers, or request bodies.
      debugPrint(
        'Gagal mendaftarkan perangkat (HTTP ${error.response?.statusCode ?? 'network'}).',
      );
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
    // Manual foreground display. Do not also enable iOS foreground presentation
    // options in FirebaseMessaging, or iOS can show a duplicate banner.
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
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'Informasi dan pengumuman kampus',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: _stringValue(message.data['route']),
    );
  }

  void _navigateFromData(Map<String, dynamic> data) {
    _navigateToRoute(_stringValue(data['route']));
  }

  void _navigateToRoute(String? route) {
    if (route == null ||
        route.isEmpty ||
        !route.startsWith('/') ||
        route.startsWith('//')) {
      return;
    }

    // Uses the injected app-level GoRouter. No BuildContext is retained/read.
    router.go(route);
  }

  String? _stringValue(Object? value) => value is String ? value : null;
}
