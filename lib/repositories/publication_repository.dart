import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/publication.dart';
import '../models/reader_session.dart';

class PublicationRepository {
  final ApiClient _client = ApiClient();

  /// Get catalog by type:
  /// weekly | monthly | yearly | brochure | archive | file
  ///
  /// [lang] — optional Accept-Language override ('en','om','am','ti',…)
  Future<List<Publication>> catalog({
    required String type,
    int page = 1,
    int limit = 20,
    String? lang,
  }) async {
    try {
      final response = await _client.dio.get(
        'read/catalog',
        queryParameters: {'type': type, 'page': page, 'limit': limit},
        options: lang != null
            ? Options(headers: {'Accept-Language': lang})
            : null,
      );

      final items = _extractList(response.data);
      if (items == null) {
        debugPrint('Catalog: unexpected envelope for type=$type');
        return _getMock(type);
      }

      return items
          .whereType<Map>()
          .map((j) => Publication.fromJson(Map<String, dynamic>.from(j)))
          .toList();
    } on DioException catch (e) {
      debugPrint('Catalog network error for $type: ${e.message}');
      return _getMock(type);
    } catch (e) {
      debugPrint('Catalog parse error for $type: $e');
      return _getMock(type);
    }
  }

  /// Start a secure reader session.
  /// Returns null on failure (caller should show a friendly error).
  Future<ReaderSession?> startSession({
    required String type,
    required String bookId,
  }) async {
    try {
      final response = await _client.dio.post(
        'read/session',
        data: {'type': type, 'book_id': bookId},
      );

      final data = _extractData(response.data);
      if (data == null) {
        debugPrint('Reader session: unexpected envelope');
        return null;
      }

      return ReaderSession.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      debugPrint('Reader session error [$status]: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Reader session parse error: $e');
      return null;
    }
  }

  /// Save reading progress. Silent failure — never blocks the UI.
  Future<void> saveProgress({
    required String type,
    required String bookId,
    required int page,
    required int pageCount,
  }) async {
    try {
      await _client.dio.post(
        'read/progress',
        data: {
          'type': type,
          'book_id': bookId,
          'page': page,
          'page_count': pageCount,
        },
      );
    } catch (e) {
      debugPrint('Progress save error: $e');
    }
  }

  // ==================== ENVELOPE HELPERS ====================

  /// Try common envelope shapes:
  ///   {success, data: [ ... ] }
  ///   {success, data: {items: [ ... ]} }
  ///   {success, data: {data: [ ... ]}}
  List<dynamic>? _extractList(dynamic body) {
    if (body is! Map) return null;
    if (body['success'] != true) return null;
    final data = body['data'];
    if (data is List) return data;
    if (data is Map) {
      if (data['items'] is List) return data['items'] as List;
      if (data['data'] is List) return data['data'] as List;
    }
    return null;
  }

  /// Same as above but for single-object endpoints.
  Map<String, dynamic>? _extractData(dynamic body) {
    if (body is! Map) return null;
    if (body['success'] != true) return null;
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  // ==================== MOCK FALLBACK ====================

  List<Publication> _getMock(String type) {
    final covers = [
      'https://picsum.photos/seed/${type}1/400/550',
      'https://picsum.photos/seed/${type}2/400/550',
      'https://picsum.photos/seed/${type}3/400/550',
      'https://picsum.photos/seed/${type}4/400/550',
    ];
    return List.generate(4, (i) {
      return Publication(
        id: '${type}_${i + 1}',
        title: 'Kallacha ${_labelFor(type)} ${i + 1}',
        subtitle: 'Issue ${i + 1}',
        coverUrl: covers[i],
        type: type,
        publishedAt: DateTime.now().subtract(Duration(days: (i + 1) * 7)),
        pageCount: 20 + (i * 5),
        issueNumber: i + 1,
      );
    });
  }

  String _labelFor(String type) {
    switch (type) {
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Quarterly';
      case 'yearly':
        return 'Yearly';
      case 'brochure':
        return 'Brochure';
      case 'archive':
        return 'Archive';
      case 'file':
        return 'Book';
      default:
        return 'Publication';
    }
  }
}