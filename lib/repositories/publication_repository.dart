import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/publication.dart';

class PublicationRepository {
  Map<String, dynamic>? _data;

  Future<Map<String, dynamic>> _loadData() async {
    if (_data != null) return _data!;
    final jsonString =
        await rootBundle.loadString('assets/mock/publications.json');
    _data = json.decode(jsonString) as Map<String, dynamic>;
    return _data!;
  }

  Future<List<Publication>> getByType(String slug) async {
    final data = await _loadData();
    final list = data[slug] as List<dynamic>? ?? [];
    return list.map((j) => Publication.fromJson(j)).toList();
  }

  Future<List<Publication>> getArchive({String? filterType}) async {
    final list = await getByType('archive');
    if (filterType == null || filterType == 'all') return list;
    return list.where((p) => p.type == filterType).toList();
  }
}