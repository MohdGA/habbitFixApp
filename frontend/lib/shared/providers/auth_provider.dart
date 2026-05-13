import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<Map<String, dynamic>?> build() async {
    // Load current user from storage on app start
    return null;
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final creds = await ref.read(authRepositoryProvider).login(
        email: email,
        password: password,
      );
      state = AsyncData(creds.user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String displayName,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final creds = await ref.read(authRepositoryProvider).register(
        email: email,
        username: username,
        displayName: displayName,
        password: password,
      );
      state = AsyncData(creds.user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
