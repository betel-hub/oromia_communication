import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/government.dart';
import '../repositories/government_repository.dart';

final governmentRepositoryProvider = Provider<GovernmentRepository>((ref) {
  return GovernmentRepository();
});

final regionalSectorsProvider = FutureProvider<List<RegionalSector>>((ref) async {
  return ref.watch(governmentRepositoryProvider).getRegionalSectors();
});

final zonesProvider = FutureProvider<List<GovRegion>>((ref) async {
  return ref.watch(governmentRepositoryProvider).getZones();
});

final citiesProvider = FutureProvider<List<GovRegion>>((ref) async {
  return ref.watch(governmentRepositoryProvider).getCities();
});

final woredasProvider = FutureProvider.family<List<GovRegion>, int>((ref, zoneId) async {
  return ref.watch(governmentRepositoryProvider).getWoredas(zoneId);
});

final subCitiesProvider = FutureProvider.family<List<GovRegion>, int>((ref, cityId) async {
  return ref.watch(governmentRepositoryProvider).getSubCities(cityId);
});

final kebelesProvider = FutureProvider.family<List<GovRegion>, int>((ref, parentId) async {
  return ref.watch(governmentRepositoryProvider).getKebeles(parentId);
});