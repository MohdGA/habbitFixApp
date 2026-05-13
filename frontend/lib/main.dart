import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF09090B),
    ),
  );

  await Hive.initFlutter();
  // Open all Hive boxes required by offline support (spec)
  await Future.wait([
    Hive.openBox<dynamic>('habits'),
    Hive.openBox<dynamic>('stats'),
    Hive.openBox<dynamic>('pendingCheckins'),
    Hive.openBox<dynamic>('ai_chat'),
    Hive.openBox<dynamic>('user'),
    Hive.openBox<dynamic>('ai_pending'),
  ]);

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase optional in dev without google-services.json
  }

  runApp(const ProviderScope(child: HabbitFixApp()));
}

class HabbitFixApp extends ConsumerStatefulWidget {
  const HabbitFixApp({super.key});

  @override
  ConsumerState<HabbitFixApp> createState() => _HabbitFixAppState();
}

class _HabbitFixAppState extends ConsumerState<HabbitFixApp> {
  // Security rule F3: cover screen contents when app goes inactive
  // to prevent sensitive data appearing in the OS task switcher.
  bool _showPrivacyShield = false;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onInactive: () => setState(() => _showPrivacyShield = true),
      onResume: () => setState(() => _showPrivacyShield = false),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'habbitFix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      builder: (context, child) {
        final content = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );

        if (_showPrivacyShield) {
          return Stack(
            children: [
              content,
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0xFF09090B),
                  child: Center(
                    child: Text('🔒', style: TextStyle(fontSize: 48)),
                  ),
                ),
              ),
            ],
          );
        }

        return content;
      },
    );
  }
}
