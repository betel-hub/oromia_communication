import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/news.dart';

class NewsRepository {
  static const bool useMock = true;

  Future<List<News>> getAllNews() async {
    if (useMock) {
      final jsonString = await rootBundle.loadString('assets/mock/news.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => News.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<News>> getByCategory(String categorySlug) async {
    final all = await getAllNews();
    if (categorySlug == 'all') return all;
    return all.where((n) => n.categorySlug == categorySlug).toList();
  }

  Future<List<News>> getFeatured() async {
    final all = await getAllNews();
    return all.where((n) => n.isFeatured).toList();
  }

  Future<News?> getById(int id) async {
    final all = await getAllNews();
    try {
      return all.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<News>> getRelated(int id, String categorySlug) async {
    final all = await getAllNews();
    return all
        .where((n) => n.categorySlug == categorySlug && n.id != id)
        .take(5)
        .toList();
  }
}