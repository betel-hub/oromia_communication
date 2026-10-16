import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central HTTP client for the OCB v1 API.
///
/// - Attaches `X-APP-KEY`, `X-DEVICE-ID`, `X-APP-VERSION` to every request.
/// - Attaches `Authorization: Bearer <access_token>` when available.
/// - Attaches `Accept-Language` from the user's selected app language.
/// - Auto-refreshes on 401 exactly once per request, then retries.
/// - Clears tokens if refresh itself fails (forces re-login).
class ApiClient {
  // ============ CONFIG ============
  static const String baseUrl =
      'https://www.oromiacommunication.gov.et/api/v1/';

  static const String appKey =
      'ocb_flutter_app_key_7f3a9c2e1b8d4e6f0a5c9d2e8b1f4a7c';

  // ============ STORAGE KEYS ============
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kDeviceId = 'device_id';
  static const _kAppLanguage = 'app_language';

  /// Languages supported by the backend (per OCB API doc).
  static const Set<String> _supportedLangs = {
    'en', 'om', 'am', 'ti', 'so', 'aa',
  };

  // ============ SINGLETON ============
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  /// In-flight refresh — prevents multiple simultaneous refresh calls.
  Future<String?>? _refreshing;

  /// Cached identity / lang values (loaded once).
  String? _deviceId;
  String? _appVersion;
  String? _cachedLang;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'X-APP-KEY': appKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Identity headers on every request.
          options.headers['X-DEVICE-ID'] = await _ensureDeviceId();
          options.headers['X-APP-VERSION'] = await _ensureAppVersion();

          // Content language.
          options.headers['Accept-Language'] = await _currentLang();

          // Bearer token when present.
          final token = await _secure.read(key: _kAccessToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (err, handler) async {
          final status = err.response?.statusCode;

          // 401 → refresh once, then retry.
          if (status == 401) {
            final retried = await _tryRefreshAndRetry(err.requestOptions);
            if (retried != null) {
              return handler.resolve(retried);
            }
            await clearTokens();
            return handler.next(err);
          }

          return handler.next(err);
        },
      ),
    );
  }

  // ==================== PUBLIC API ====================

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secure.write(key: _kAccessToken, value: accessToken);
    await _secure.write(key: _kRefreshToken, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _secure.delete(key: _kAccessToken);
    await _secure.delete(key: _kRefreshToken);
  }

  Future<String?> getAccessToken() => _secure.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _secure.read(key: _kRefreshToken);

  Future<bool> get isLoggedIn async {
    final t = await _secure.read(key: _kAccessToken);
    return t != null && t.isNotEmpty;
  }

  Future<String> ensureDeviceId() => _ensureDeviceId();

  /// Invalidate the cached language so the next request re-reads it.
  /// Call this whenever the user changes the app language.
  void invalidateLanguageCache() {
    _cachedLang = null;
  }

  // ==================== INTERNALS ====================

  Future<String> _ensureDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kDeviceId);
    if (id == null || id.isEmpty) {
      id = _generateUuidV4();
      await prefs.setString(_kDeviceId, id);
    }
    _deviceId = id;
    return id;
  }

  Future<String> _ensureAppVersion() async {
    if (_appVersion != null) return _appVersion!;
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {
      _appVersion = '1.0.0+1';
    }
    return _appVersion!;
  }

  /// Read the user's selected language from SharedPreferences.
  /// Defaults to 'en' if unset or unsupported.
  Future<String> _currentLang() async {
    if (_cachedLang != null) return _cachedLang!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kAppLanguage);
      if (code != null && _supportedLangs.contains(code)) {
        _cachedLang = code;
        return code;
      }
    } catch (_) {
      // Fall through to default.
    }
    _cachedLang = 'en';
    return 'en';
  }

  Future<Response<dynamic>?> _tryRefreshAndRetry(
    RequestOptions original,
  ) async {
    if (original.extra['__retried'] == true) return null;
    original.extra['__retried'] = true;

    final newToken = await _refreshAccessToken();
    if (newToken == null) return null;

    final headers = Map<String, dynamic>.from(original.headers);
    headers['Authorization'] = 'Bearer $newToken';

    try {
      return await dio.request<dynamic>(
        original.path,
        data: original.data,
        queryParameters: original.queryParameters,
        cancelToken: original.cancelToken,
        options: Options(
          method: original.method,
          headers: headers,
          contentType: original.contentType,
          responseType: original.responseType,
          followRedirects: original.followRedirects,
          receiveDataWhenStatusError: original.receiveDataWhenStatusError,
          extra: original.extra,
        ),
      );
    } on DioException catch (e) {
      debugPrint('OCB refresh retry failed: ${e.message}');
      return null;
    }
  }

  Future<String?> _refreshAccessToken() {
    _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
    return _refreshing!;
  }

  Future<String?> _doRefresh() async {
    final refresh = await _secure.read(key: _kRefreshToken);
    if (refresh == null || refresh.isEmpty) return null;

    try {
      // Bare Dio — avoids re-entering the interceptor.
      final bare = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'X-APP-KEY': appKey,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      final res = await bare.post<Map<String, dynamic>>(
        'auth/refresh',
        data: {'refresh_token': refresh},
      );

      final data = res.data;
      if (data == null || data['success'] != true) return null;

      final payload = data['data'] as Map<String, dynamic>?;
      if (payload == null) return null;

      final newAccess = payload['access_token'] as String?;
      final newRefresh = payload['refresh_token'] as String?;
      if (newAccess == null || newAccess.isEmpty) return null;

      await _secure.write(key: _kAccessToken, value: newAccess);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await _secure.write(key: _kRefreshToken, value: newRefresh);
      }
      return newAccess;
    } on DioException catch (e) {
      debugPrint('OCB refresh failed: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('OCB refresh failed: $e');
      return null;
    }
  }

  static String _generateUuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;
    String hex(int n) => n.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-'
        '${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-'
        '${h.substring(20)}';
  }
}