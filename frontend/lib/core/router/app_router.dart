import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/habits/presentation/screens/habits_screen.dart';
import '../../features/habits/presentation/screens/add_habit_screen.dart';
import '../../features/habits/presentation/screens/edit_habit_screen.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/habits/data/habits_repository.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/ai/presentation/screens/ai_chat_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/delete_account_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../storage/secure_storage.dart';

// Deep link param validation (security rule F6)
final _userIdPattern = RegExp(r'^[0-9a-f\-]{36}$');   // UUID v4
final _tokenPattern  = RegExp(r'^[0-9a-f]{80}$');      // 40-byte hex

final appRouterProvider = Provider<GoRouter>((ref) {
  final storage = ref.read(secureStorageProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      final isAuth = await storage.hasTokens();

      final publicRoutes = {
        '/splash', '/onboarding', '/login', '/register',
        '/forgot-password', '/verify-email',
      };
      final isPublic = publicRoutes.contains(loc) ||
          loc.startsWith('/reset-password');

      if (!isAuth && !isPublic) return '/login';
      if (isAuth && (loc == '/login' || loc == '/register')) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // Deep link: /reset-password?uid=...&token=...
      GoRoute(
        path: '/reset-password',
        redirect: (_, state) {
          final uid = state.uri.queryParameters['uid'] ?? '';
          final token = state.uri.queryParameters['token'] ?? '';
          // Validate params before rendering (security rule F6)
          if (!_userIdPattern.hasMatch(uid) || !_tokenPattern.hasMatch(token)) {
            return '/login?error=invalid_reset_link';
          }
          return null;
        },
        builder: (_, state) {
          final uid = state.uri.queryParameters['uid']!;
          final token = state.uri.queryParameters['token']!;
          return ResetPasswordScreen(userId: uid, token: token);
        },
      ),

      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/delete-account',
        builder: (_, __) => const DeleteAccountScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/habits',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HabitsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddHabitScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (_, state) {
                  final habit = state.extra as Habit;
                  return EditHabitScreen(habit: habit);
                },
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    HabitDetailScreen(habitId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProgressScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/ai',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AiChatScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/community',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CommunityScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Center(
        child: Text(
          'Page not found',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
});

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) =>
    FadeTransition(opacity: animation, child: child);
