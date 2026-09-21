import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tender.dart';
import '../repositories/tender_repository.dart';

final tenderRepositoryProvider = Provider<TenderRepository>((ref) {
  return TenderRepository();
});

final tendersProvider = FutureProvider<List<Tender>>((ref) async {
  return ref.watch(tenderRepositoryProvider).getTenders();
});