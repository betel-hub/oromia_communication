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

      if (response.data['success'] == true) {
        final items = response.data['data']['items'] as List<dynamic>;
        return items.map((j) => News.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading news: $e');
      return [];
    }
  }

  // ============ BY CATEGORY ============
  // TODO: Backend does not yet support category filter.
  // Currently returns all news. Update when backend is fixed.
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
          'category': slug == 'all' ? null : slug,
        },
      );

      if (response.data['success'] == true) {
        final items = response.data['data']['items'] as List<dynamic>;
        return items.map((j) => News.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading category news: $e');
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
      if (response.data['success'] == true) {
        return News.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading news detail: $e');
      return null;
    }
  }

  // ============ RELATED ============
  Future<List<News>> getRelated(String id, String categorySlug) async {
    final list = await getByCategory(categorySlug, limit: 6);
    return list.where((n) => n.id != id).take(5).toList();
  }

  // ============ SEARCH ============
  Future<List<Map<String, dynamic>>> search(String query,
      {String lang = 'en'}) async {
    try {
      final response = await _client.dio.get(
        'search',
        queryParameters: {'q': query, 'lang': lang, 'limit': 20},
      );
      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(
            response.data['data']['items'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error searching: $e');
      return [];
    }
  }
}