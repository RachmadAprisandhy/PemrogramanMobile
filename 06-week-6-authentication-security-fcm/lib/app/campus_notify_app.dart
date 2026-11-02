import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import 'app_router.dart';

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  late final _AuthRouterRefresh _authRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRefresh = _AuthRouterRefresh();
    _router = createAppRouter(
      refreshListenable: _authRefresh,
      readAuthenticated: () => ref
          .read(authStateProvider)
          .when(
            data: (authenticated) => authenticated,
            loading: () => null,
            error: (_, _) => false,
          ),
    );

    unawaited(_initializePushHandlers());
  }

  Future<void> _initializePushHandlers() async {
    try {
      await ref.read(pushServiceProvider(_router)).initialize();
    } catch (error) {
      debugPrint('Gagal menyiapkan notifikasi: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      _authRefresh.refresh();
    });

    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _authRefresh.dispose();
    super.dispose();
  }
}

class _AuthRouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}
