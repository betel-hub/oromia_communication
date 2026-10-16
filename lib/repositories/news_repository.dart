import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/news.dart';

class NewsRepository {
  final ApiClient _client = ApiClient();

  // ============ ALL NEWS ============
  Future<List<News>> getAllNews({int page = 1, int limit = 20}) async {
    try {
      final response = await _client.dio.get(
        'news',
        queryParameters: {'page': page, 'limit': limit},
      );

      final items = _extractList(response.data);
      if (items == null) return [];

      return items
          .whereType<Map>()
          .map((j) => News.fromJson(Map<String, dynamic>.from(j)))
          .toList();
    } on DioException catch (e) {
      debugPrint('Error loading news: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error parsing news: $e');
      return [];
    }
  }

  // ============ BY CATEGORY ============
  Future<List<News>> getByCategory(
    String slug, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.dio.get(
        'news',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (slug != 'all') 'category': slug,
        },
      );

      final items = _extractList(response.data);
      if (items == null) return [];

      return items
          .whereType<Map>()
          .map((j) => News.fromJson(Map<String, dynamic>.from(j)))
          .toList();
    } on DioException catch (e) {
      debugPrint('Error loading category news: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error parsing category news: $e');
      return [];
    }
  }

  // ============ FEATURED ============
  Future<List<News>> getFeatured() async {
    final all = await getAllNews(limit: 10);
    return all.take(5).toList();
  }

  // ============ DETAIL ============
  Future<News?> getById(String id) async {
    try {
      final response = await _client.dio.get('news/$id');
      final data = _extractData(response.data);
      if (data == null) return null;
      return News.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Error loading news detail: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error parsing news detail: $e');
      return null;
    }
  }

  // ============ RELATED ============
  Future<List<News>> getRelated(String id, String categorySlug) async {
    final list = await getByCategory(categorySlug, limit: 6);
    return list.where((n) => n.id != id).take(5).toList();
  }

  // ============ SEARCH ============
  Future<List<Map<String, dynamic>>> search(
    String query, {
    String lang = 'en',
  }) async {
    try {
      final response = await _client.dio.get(
        'search',
        queryParameters: {'q': query, 'lang': lang, 'limit': 20},
      );

      final items = _extractList(response.data);
      if (items == null) return [];

      return items
          .whereType<Map>()
          .map((j) => Map<String, dynamic>.from(j))
          .toList();
    } on DioException catch (e) {
      debugPrint('Error searching: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error parsing search: $e');
      return [];
    }
  }

  // ==================== ENVELOPE HELPERS ====================

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

  Map<String, dynamic>? _extractData(dynamic body) {
    if (body is! Map) return null;
    if (body['success'] != true) return null;
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}