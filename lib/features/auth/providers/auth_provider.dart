import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../shared/models/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.loading = false,
  });

  final AuthStatus status;
  final User? user;
  final String? error;
  final bool loading;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? loading,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      loading: loading ?? this.loading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._api) : super(const AuthState()) {
    _bootstrap();
  }

  final ApiClient _api;

  Future<void> _bootstrap() async {
    if (_api.isLoggedIn) {
      final cached = _api.cachedUser;
      state = AuthState(
        status: AuthStatus.authenticated,
        user: cached,
      );
      // Refresh profile in background
      try {
        final me = await _api.me();
        state = state.copyWith(user: me, status: AuthStatus.authenticated);
      } catch (_) {
        // keep cached; if 401 interceptor clears tokens, re-check
        if (!_api.isLoggedIn) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({
    required String phoneOrEmail,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final session = await _api.login(
        phoneOrEmail: phoneOrEmail,
        password: password,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: session.user,
        loading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: apiErrorMessage(e),
        status: AuthStatus.unauthenticated,
      );
      return false;
    }
  }

  Future<bool> register({
    String? phone,
    String? email,
    required String password,
    String? fullName,
    String? referralCode,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final session = await _api.register(
        phone: phone,
        email: email,
        password: password,
        fullName: fullName,
        referralCode: referralCode,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: session.user,
        loading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: apiErrorMessage(e),
        status: AuthStatus.unauthenticated,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiClientProvider));
});
