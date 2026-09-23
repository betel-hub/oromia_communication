import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/news.dart';
import '../repositories/news_repository.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

// ============ ALL NEWS ============
final allNewsProvider = FutureProvider<List<News>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getAllNews();
});

// ============ FEATURED ============
final featuredNewsProvider = FutureProvider<List<News>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getFeatured();
});

// ============ BY CATEGORY ============
final categoryNewsProvider =
    FutureProvider.family<List<News>, String>((ref, categorySlug) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getByCategory(categorySlug);
});

// ============ DETAIL (String UUID) ============
final newsDetailProvider =
    FutureProvider.family<News?, String>((ref, id) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getById(id);
});

// ============ RELATED ============
final relatedNewsProvider =
    FutureProvider.family<List<News>, Map<String, dynamic>>((ref, params) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getRelated(
    params['id'] as String,
    params['categorySlug'] as String,
  );
});