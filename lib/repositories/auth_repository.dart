import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthRepository {
  static const _usersKey = 'registered_users';
  static const _sessionKey = 'current_user_email';
  static const _tokenKey = 'access_token';
  static const _otpKey = 'pending_otp';
  static const _otpEmailKey = 'pending_otp_email';
  static const _otpExpiryKey = 'pending_otp_expiry';

  // ==================== HELPERS ====================

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Load all registered users (persisted in SharedPreferences)
  Future<Map<String, Map<String, dynamic>>> _loadUsers() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    final Map<String, dynamic> decoded = json.decode(raw);
    return decoded.map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v)));
  }

  Future<void> _saveUsers(Map<String, Map<String, dynamic>> users) async {
    final prefs = await _prefs;
    await prefs.setString(_usersKey, json.encode(users));
  }

  /// Generate 6-digit OTP
  String _generateOtp() {
    final rnd = Random();
    return (100000 + rnd.nextInt(900000)).toString();
  }

  // ==================== REGISTRATION ====================

  /// Step 1: Start registration — creates pending user + OTP
  /// Returns the OTP (in real app, this would be sent via email)
  Future<String> startRegistration({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final users = await _loadUsers();
    final key = email.toLowerCase();

    if (users.containsKey(key)) {
      throw Exception('Email already registered. Please login.');
    }

    // Create pending user (unverified)
    users[key] = {
      'id': users.length + 1,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password, // 🔒 In real app: hash this
      'type': 'public_user',
      'is_verified': false,
      'created_at': DateTime.now().toIso8601String(),
    };
    await _saveUsers(users);

    // Generate OTP
    final otp = _generateOtp();
    final prefs = await _prefs;
    await prefs.setString(_otpKey, otp);
    await prefs.setString(_otpEmailKey, key);
    await prefs.setInt(
      _otpExpiryKey,
      DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch,
    );

    // In a real app: send OTP via backend API call here
    // await _api.post('/auth/send-otp', {'email': email, 'otp': otp});

    return otp;
  }

  /// Step 2: Verify OTP — activates the account
  Future<User> verifyOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final prefs = await _prefs;
    final storedOtp = prefs.getString(_otpKey);
    final pendingEmail = prefs.getString(_otpEmailKey);
    final expiry = prefs.getInt(_otpExpiryKey);

    if (storedOtp == null || pendingEmail == null) {
      throw Exception('No pending verification');
    }

    if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
      throw Exception('OTP expired. Please request a new one.');
    }

    if (otp.trim() != storedOtp) {
      throw Exception('Invalid OTP. Please try again.');
    }

    // Mark user verified
    final users = await _loadUsers();
    final userData = users[pendingEmail];
    if (userData == null) throw Exception('User not found');

    userData['is_verified'] = true;
    users[pendingEmail] = userData;
    await _saveUsers(users);

    // Clear OTP
    await prefs.remove(_otpKey);
    await prefs.remove(_otpEmailKey);
    await prefs.remove(_otpExpiryKey);

    // Log the user in
    await prefs.setString(_sessionKey, pendingEmail);
    await prefs.setString(_tokenKey, 'token_${userData['id']}');

    return User.fromJson(userData);
  }

  /// Resend OTP
  Future<String> resendOtp() async {
    final prefs = await _prefs;
    final pendingEmail = prefs.getString(_otpEmailKey);
    if (pendingEmail == null) throw Exception('No pending verification');

    final otp = _generateOtp();
    await prefs.setString(_otpKey, otp);
    await prefs.setInt(
      _otpExpiryKey,
      DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch,
    );
    return otp;
  }

  // ==================== LOGIN ====================

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final users = await _loadUsers();
    final key = email.toLowerCase();
    final userData = users[key];

    if (userData == null) {
      throw Exception('No account found for this email. Please register.');
    }
    if (userData['password'] != password) {
      throw Exception('Incorrect password');
    }
    if (userData['is_verified'] != true) {
      throw Exception('Account not verified. Please verify with OTP.');
    }

    final prefs = await _prefs;
    await prefs.setString(_sessionKey, key);
    await prefs.setString(_tokenKey, 'token_${userData['id']}');

    return User.fromJson(userData);
  }

  // ==================== SESSION ====================

  Future<User?> getCurrentUser() async {
    final prefs = await _prefs;
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;

    final users = await _loadUsers();
    final userData = users[email];
    if (userData == null) return null;

    return User.fromJson(userData);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getString(_sessionKey) != null;
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionKey);
    await prefs.remove(_tokenKey);
  }

  // ==================== FORGOT PASSWORD ====================

  /// Step 1: Request password reset OTP
  Future<String> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final users = await _loadUsers();
    final key = email.toLowerCase();
    if (!users.containsKey(key)) {
      // Don't leak whether email exists — still return OTP
      return _generateOtp();
    }

    final otp = _generateOtp();
    final prefs = await _prefs;
    await prefs.setString(_otpKey, otp);
    await prefs.setString(_otpEmailKey, key);
    await prefs.setInt(
      _otpExpiryKey,
      DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch,
    );

    // In real app: send OTP via email
    return otp;
  }

  /// Step 2: Reset password using OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final prefs = await _prefs;
    final storedOtp = prefs.getString(_otpKey);
    final pendingEmail = prefs.getString(_otpEmailKey);

    if (storedOtp == null || pendingEmail != email.toLowerCase()) {
      throw Exception('No pending password reset');
    }
    if (otp.trim() != storedOtp) {
      throw Exception('Invalid OTP');
    }

    final users = await _loadUsers();
    final userData = users[email.toLowerCase()];
    if (userData == null) throw Exception('User not found');

    userData['password'] = newPassword;
    users[email.toLowerCase()] = userData;
    await _saveUsers(users);

    await prefs.remove(_otpKey);
    await prefs.remove(_otpEmailKey);
    await prefs.remove(_otpExpiryKey);
  }
}