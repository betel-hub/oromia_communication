import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'news_provider.dart';

/// Holds current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Fetches search results for a query
final searchResultsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final repo = ref.watch(newsRepositoryProvider);
  return repo.search(query);
});