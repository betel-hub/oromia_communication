import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/news.dart';
import '../repositories/news_repository.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

final allNewsProvider = FutureProvider<List<News>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getAllNews();
});

final featuredNewsProvider = FutureProvider<List<News>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getFeatured();
});

final categoryNewsProvider =
    FutureProvider.family<List<News>, String>((ref, categorySlug) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getByCategory(categorySlug);
});

final newsDetailProvider =
    FutureProvider.family<News?, int>((ref, id) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getById(id);
});

final relatedNewsProvider =
    FutureProvider.family<List<News>, Map<String, dynamic>>((ref, params) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getRelated(params['id'], params['categorySlug']);
});