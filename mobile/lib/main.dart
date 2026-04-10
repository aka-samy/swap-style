import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    debugPrint(details.stack.toString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught Zone Error: $error');
    debugPrint(stack.toString());
    return true;
  };

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const ProviderScope(child: SwapStyleApp()));
}

class SwapStyleApp extends ConsumerStatefulWidget {
  const SwapStyleApp({super.key});

  @override
  ConsumerState<SwapStyleApp> createState() => _SwapStyleAppState();
}

class _SwapStyleAppState extends ConsumerState<SwapStyleApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(authProvider.notifier).checkAuthStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Swap Style',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
