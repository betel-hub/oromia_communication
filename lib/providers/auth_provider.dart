import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final String? pendingEmail;
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

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final repo = _ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  // ==================== REGISTRATION ====================

  Future<String?> startRegistration({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final otp = await repo.startRegistration(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      state = state.copyWith(
        isLoading: false,
        pendingEmail: email,
        devOtp: otp,
      );
      return otp;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.verifyOtp(otp);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<String?> resendOtp() async {
    try {
      final repo = _ref.read(authRepositoryProvider);
      final otp = await repo.resendOtp();
      state = state.copyWith(devOtp: otp, clearError: true);
      return otp;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  // ==================== LOGIN ====================

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    final repo = _ref.read(authRepositoryProvider);
    await repo.logout();
    state = AuthState();
  }

  // ==================== FORGOT PASSWORD ====================

  Future<String?> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final otp = await repo.requestPasswordReset(email);
      state = state.copyWith(
        isLoading: false,
        pendingEmail: email,
        devOtp: otp,
      );
      return otp;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // ==================== HELPERS ====================

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}