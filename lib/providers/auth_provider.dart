import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';

// ==================== PROVIDERS ====================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// ==================== STATE ====================

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  /// Identifier the user registered / is resetting with.
  /// Used to support "resend OTP" without asking them to re-enter it.
  final String? pendingEmail;

  /// Kept for API compatibility with existing screens.
  /// Always null now — real OTPs are delivered by email/SMS.
  final String? devOtp;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.pendingEmail,
    this.devOtp,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    String? pendingEmail,
    String? devOtp,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      pendingEmail: pendingEmail ?? this.pendingEmail,
      devOtp: devOtp ?? this.devOtp,
    );
  }
}

// ==================== NOTIFIER ====================

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState()) {
    _checkAuth();
  }

  /// On app start: if a valid token exists, load the user profile.
  /// Safe — silently returns if not logged in or network fails.
  Future<void> _checkAuth() async {
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.getCurrentUser();
      if (user != null && mounted) {
        state = state.copyWith(user: user, clearError: true);
      }
    } catch (_) {
      // Silent — splash/home will show logged-out UI.
    }
  }

  // ==================== REGISTRATION ====================

  /// Returns true on success. The `String?` return type is kept so any
  /// existing screens calling `.startRegistration(...) != null` still work,
  /// but it will always be null now (production: no dev OTP echoed back).
  Future<String?> startRegistration({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    if (state.isLoading) return null;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.startRegistration(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      if (!mounted) return null;
      state = state.copyWith(
        isLoading: false,
        pendingEmail: email,
        clearError: true,
      );
      return null; // success
    } on AuthException catch (e) {
      if (!mounted) return null;
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      if (!mounted) return null;
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }

  /// Verify the OTP the user typed. On success, logs them in.
  Future<bool> verifyOtp(String otp) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.verifyOtp(otp);
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      return true;
    } on AuthException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Could not verify OTP. Please try again.',
      );
      return false;
    }
  }

  /// Ask the server to resend the OTP. Returns true if the request succeeded.
  Future<bool> resendOtp() async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.resendOtp();
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, clearError: true);
      return true;
    } on AuthException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Could not resend OTP. Please try again.',
      );
      return false;
    }
  }

  // ==================== LOGIN ====================

  Future<bool> login(String identifier, String password) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.login(identifier, password);
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      return true;
    } on AuthException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Could not log in. Please try again.',
      );
      return false;
    }
  }

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    final repo = _ref.read(authRepositoryProvider);
    await repo.logout();
    if (!mounted) return;
    state = AuthState();
  }

  // ==================== FORGOT PASSWORD ====================

  /// Send a password reset link/OTP. Always succeeds (no enumeration).
  /// Returns null on success (kept for screen compatibility).
  Future<String?> requestPasswordReset(String identifier) async {
    if (state.isLoading) return null;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.requestPasswordReset(identifier);
      if (!mounted) return null;
      state = state.copyWith(
        isLoading: false,
        pendingEmail: identifier,
        clearError: true,
      );
      return null; // success
    } on AuthException catch (e) {
      if (!mounted) return null;
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (_) {
      if (!mounted) return null;
      state = state.copyWith(
        isLoading: false,
        error: 'Could not send reset link. Please try again.',
      );
      return null;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, clearError: true);
      return true;
    } on AuthException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Could not reset password. Please try again.',
      );
      return false;
    }
  }

  // ==================== HELPERS ====================

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}