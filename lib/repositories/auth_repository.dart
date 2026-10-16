import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/user.dart';

/// Thrown when an auth operation fails. Message is human-readable.
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthRepository {
  final ApiClient _client = ApiClient();

  // ==================== REGISTER ====================

  /// Step 1: Create a pending account.
  /// Returns null (OTP is delivered by email/SMS, not by the API).
  ///
  /// Throws [AuthException] on failure (duplicate email, bad phone, etc).
  Future<String?> startRegistration({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        'auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      _ensureSuccess(res);
      return null;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Step 2: Verify the phone (or email) OTP. On success, user is logged in.
  Future<User> verifyOtp(String otp) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        'auth/verify-phone',
        data: {'code': otp},
      );
      _ensureSuccess(res);
      return await _persistTokensAndFetchUser(res.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Resend the OTP. Returns null (no dev OTP).
  Future<String?> resendOtp() async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        'auth/send-phone-otp',
      );
      _ensureSuccess(res);
      return null;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ==================== LOGIN ====================

  /// Log in with email+password or phone+password.
  /// If [email] looks like a phone number, sends it as `phone`.
  Future<User> login(String identifier, String password) async {
    try {
      final isPhone = _looksLikePhone(identifier);
      final body = <String, dynamic>{
        if (isPhone) 'phone': identifier else 'email': identifier,
        'password': password,
      };

      final res = await _client.dio.post<Map<String, dynamic>>(
        'auth/login',
        data: body,
      );
      _ensureSuccess(res);
      return await _persistTokensAndFetchUser(res.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ==================== SESSION ====================

  /// Load the current user from `/auth/me` if a token exists.
  /// Returns null if not logged in or if the call fails (safe for splash).
  Future<User?> getCurrentUser() async {
    if (!await _client.isLoggedIn) return null;
    try {
      final res = await _client.dio.get<Map<String, dynamic>>('auth/me');
      if (res.data?['success'] != true) return null;
      final data = res.data?['data'];
      if (data is Map<String, dynamic>) {
        return User.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() => _client.isLoggedIn;

  Future<void> logout() async {
    // Best-effort server-side revoke; local wipe always happens.
    try {
      final refresh = await _client.getRefreshToken();
      if (refresh != null && refresh.isNotEmpty) {
        await _client.dio.post(
          'auth/logout',
          data: {'refresh_token': refresh},
        );
      }
    } catch (_) {
      // Ignore — we still clear locally.
    } finally {
      await _client.clearTokens();
    }
  }

  // ==================== FORGOT PASSWORD ====================

  /// Request a reset link/OTP. Always succeeds (no account enumeration).
  /// Returns null (no dev OTP).
  Future<String?> requestPasswordReset(String identifier) async {
    try {
      final isPhone = _looksLikePhone(identifier);
      final body = isPhone ? {'phone': identifier} : {'email': identifier};

      final res = await _client.dio.post<Map<String, dynamic>>(
        'auth/forgot-password',
        data: body,
      );
      _ensureSuccess(res);
      return null;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Complete the reset using the OTP from the email/SMS link.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      // The reset link typically embeds a token; using the OTP as the token
      // matches your server's `/auth/forgot-password` contract.
      final res = await _client.dio.post<Map<String, dynamic>>(
        'auth/forgot-password/reset',
        data: {
          'email': email,
          'token': otp,
          'password': newPassword,
        },
      );
      _ensureSuccess(res);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ==================== HELPERS ====================

  /// Persist tokens from a login/refresh response and fetch the profile.
  Future<User> _persistTokensAndFetchUser(Map<String, dynamic> envelope) async {
    final data = envelope['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw AuthException('Server returned no user data.');
    }

    final access = data['access_token'] as String?;
    final refresh = data['refresh_token'] as String?;
    if (access == null || refresh == null) {
      throw AuthException('Server returned no tokens.');
    }

    await _client.setTokens(accessToken: access, refreshToken: refresh);

    // The login response already includes `user`; use it directly if present.
    final userJson = data['user'];
    if (userJson is Map<String, dynamic>) {
      return User.fromJson(userJson);
    }

    // Fallback to `/auth/me` if the response shape ever changes.
    final me = await getCurrentUser();
    if (me == null) {
      throw AuthException('Logged in but could not load profile.');
    }
    return me;
  }

  void _ensureSuccess(Response<Map<String, dynamic>> res) {
    if (res.data?['success'] != true) {
      final msg = res.data?['message']?.toString() ?? 'Request failed.';
      throw AuthException(msg, statusCode: res.statusCode);
    }
  }

  AuthException _mapError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;

    String msg = 'Connection error. Check your internet and try again.';
    if (body is Map && body['message'] is String) {
      msg = body['message'] as String;
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      msg = 'Request timed out. Please try again.';
    } else if (status == 401) {
      msg = 'Invalid credentials.';
    } else if (status == 409) {
      msg = 'That email or phone is already registered.';
    } else if (status == 422) {
      msg = 'Please check the information you entered.';
    } else if (status == 429) {
      msg = 'Too many attempts. Please wait and try again.';
    } else if (status != null && status >= 500) {
      msg = 'Server error. Please try again later.';
    }
    return AuthException(msg, statusCode: status);
  }

  bool _looksLikePhone(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return false;
    // Ethiopian numbers: +2519…, 09…, 07…, or digits-only.
    if (trimmed.startsWith('+')) return true;
    return RegExp(r'^[0-9]{9,15}$').hasMatch(trimmed);
  }
}