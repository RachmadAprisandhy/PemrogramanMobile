import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerBackgroundHandler();
  runApp(const ProviderScope(child: CampusNotifyApp()));
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  late final _RouterRefreshNotifier _routerRefresh;
  late final GoRouter _router;
  PushService? _pushService;

  @override
  void initState() {
    super.initState();
    _routerRefresh = _RouterRefreshNotifier();
    _router = GoRouter(
      refreshListenable: _routerRefresh,
      redirect: (context, state) {
        final authState = ref.read(authStateProvider);
        if (authState.isLoading) return null;

        final loggedIn = authState.value ?? false;
        final goingLogin = state.matchedLocation == '/login';

        if (!loggedIn && !goingLogin) {
          return Uri(
            path: '/login',
            queryParameters: {'from': state.uri.toString()},
          ).toString();
        }
        if (loggedIn && goingLogin) {
          final destination = state.uri.queryParameters['from'];
          if (destination != null &&
              destination.startsWith('/') &&
              !destination.startsWith('//')) {
            return destination;
          }
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/', builder: (context, state) => const MyHomePage()),
        GoRoute(
          path: '/pengumuman/:id',
          builder: (context, state) =>
              AnnouncementPage(id: state.pathParameters['id'] ?? ''),
        ),
      ],
    );

    unawaited(_initializePushHandlers());
  }

  Future<void> _initializePushHandlers() async {
    try {
      final service = ref.read(pushServiceProvider(_router));
      _pushService = service;
      await service.initialize();
    } catch (error) {
      debugPrint('Gagal menyiapkan notifikasi: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      _routerRefresh.notifyListeners();
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
    unawaited(_pushService?.dispose());
    _router.dispose();
    _routerRefresh.dispose();
    super.dispose();
  }
}

class _RouterRefreshNotifier extends ChangeNotifier {
  @override
  void notifyListeners() => super.notifyListeners();
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Kata sandi'),
            ),
            if (authState.hasError) ...[
              const SizedBox(height: 12),
              Text(
                authState.error.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: authState.isLoading
                  ? null
                  : () => ref
                        .read(authStateProvider.notifier)
                        .login(_emailController.text, _passwordController.text),
              child: authState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/pengumuman/demo'),
          child: const Text('Buka contoh pengumuman'),
        ),
      ),
    );
  }
}

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: Center(child: Text('ID pengumuman: $id')),
    );
  }
}
