import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media.dart';
import '../repositories/media_repository.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository();
});

final mediaListProvider =
    FutureProvider.family<List<MediaItem>, String>((ref, slug) async {
  return ref.watch(mediaRepositoryProvider).getByType(slug);
});