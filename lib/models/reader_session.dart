class ReaderSession {
  final String pageUrlTemplate;
  final String? streamUrl;
  final int pageCount;
  final int resumePage;
  final ReaderSecurity security;

  ReaderSession({
    required this.pageUrlTemplate,
    this.streamUrl,
    required this.pageCount,
    this.resumePage = 1,
    required this.security,
  });

  factory ReaderSession.fromJson(Map<String, dynamic> json) {
    return ReaderSession(
      pageUrlTemplate: _asString(json['page_url_template']) ?? '',
      streamUrl: _asString(json['stream_url']),
      pageCount: _asInt(json['page_count']) ?? 1,
      resumePage: _asInt(json['resume_page']) ?? 1,
      security: ReaderSecurity.fromJson(
        _asMap(json['security']),
      ),
    );
  }
}

class ReaderSecurity {
  final bool blockScreenshots;
  final bool androidFlagSecure;
  final bool iosScreenCaptureDetect;
  final bool watermark;
  final bool downloadAllowed;
  final bool shareAllowed;

  ReaderSecurity({
    this.blockScreenshots = true,
    this.androidFlagSecure = true,
    this.iosScreenCaptureDetect = true,
    this.watermark = true,
    this.downloadAllowed = false,
    this.shareAllowed = false,
  });

  factory ReaderSecurity.fromJson(Map<String, dynamic> json) {
    return ReaderSecurity(
      blockScreenshots: _asBool(json['block_screenshots'], fallback: true),
      androidFlagSecure: _asBool(json['android_flag_secure'], fallback: true),
      iosScreenCaptureDetect:
          _asBool(json['ios_screen_capture_detect'], fallback: true),
      watermark: _asBool(json['watermark'], fallback: true),
      downloadAllowed: _asBool(json['download_allowed'], fallback: false),
      shareAllowed: _asBool(json['share_allowed'], fallback: false),
    );
  }
}

// ==================== SAFE COERCION HELPERS ====================

/// Returns null if value is not a non-empty String.
String? _asString(dynamic value) {
  if (value == null) return null;
  final s = value.toString();
  return s.isEmpty ? null : s;
}

/// Accepts int, String number, or numeric double. Returns null on failure.
int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

/// Returns a Map or empty map — never throws.
Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  return const {};
}

/// Accepts true / "true" / 1 / "1" / "yes" / "on" as true.
/// Accepts false / "false" / 0 / "0" / "no" / "off" / null as false.
/// Anything unrecognized → fallback.
bool _asBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.trim().toLowerCase();
    if (v == 'true' || v == '1' || v == 'yes' || v == 'on') return true;
    if (v == 'false' || v == '0' || v == 'no' || v == 'off' || v.isEmpty) {
      return false;
    }
  }
  return fallback;
}