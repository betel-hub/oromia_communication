import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../models/tender.dart';

class TenderRepository {
  final ApiClient _client = ApiClient();

  /// Try the real API first. Falls back to mock if API fails (network).
  Future<List<Tender>> getTenders() async {
    try {
      final response = await _client.dio.get('tenders');

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Handle different response shapes
        final List<dynamic> items;
        if (data is List) {
          items = data;
        } else if (data is Map && data['items'] is List) {
          items = data['items'];
        } else {
          return [];
        }

        return items.map((j) => Tender.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Tenders API not available, using mock: $e');
      return _getMockTenders();
    }
  }

  /// Mock data — used when API is unavailable (like now, when backend has 0)
  List<Tender> _getMockTenders() {
    return [
      Tender(
        id: 1,
        title: 'Construction of Regional Office Building',
        description:
            'Supply and construction of a new 3-story regional office building in Adama.',
        deadline: DateTime.now().add(const Duration(days: 2)),
        isFree: true,
      ),
      Tender(
        id: 2,
        title: 'Supply of IT Equipment',
        description:
            'Supply of 100 laptops and 50 desktop computers for regional offices.',
        deadline: DateTime.now().add(const Duration(days: 7)),
        isFree: true,
      ),
      Tender(
        id: 3,
        title: 'Road Rehabilitation Project',
        description:
            'Rehabilitation of 25 km of rural roads in Arsi Zone.',
        deadline: DateTime.now().add(const Duration(days: 19)),
        fee: 500,
        isFree: false,
      ),
      Tender(
        id: 4,
        title: 'Medical Supplies Procurement',
        description:
            'Supply of medical equipment and supplies for regional health centers.',
        deadline: DateTime.now().add(const Duration(days: 17)),
        isFree: true,
      ),
      Tender(
        id: 5,
        title: 'Water Infrastructure Development',
        description:
            'Construction of water supply systems in 5 rural woredas.',
        deadline: DateTime.now().add(const Duration(days: 28)),
        fee: 300,
        isFree: false,
      ),
      Tender(
        id: 6,
        title: 'Agricultural Equipment Supply',
        description:
            'Supply of modern agricultural equipment to farmer cooperatives.',
        deadline: DateTime.now().add(const Duration(days: 12)),
        isFree: true,
      ),
    ];
  }
}