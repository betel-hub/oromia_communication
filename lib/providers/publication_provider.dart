import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/publication.dart';
import '../repositories/publication_repository.dart';

final publicationRepositoryProvider = Provider<PublicationRepository>((ref) {
  return PublicationRepository();
});

final publicationListProvider =
    FutureProvider.family<List<Publication>, String>((ref, type) async {
  return ref.watch(publicationRepositoryProvider).catalog(type: type);
});