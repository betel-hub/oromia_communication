import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/media.dart';

class MediaRepository {
  Map<String, dynamic>? _data;

  Future<Map<String, dynamic>> _loadData() async {
    if (_data != null) return _data!;
    final jsonString = await rootBundle.loadString('assets/mock/media.json');
    _data = json.decode(jsonString) as Map<String, dynamic>;
    return _data!;
  }

  Future<List<MediaItem>> getByType(String slug) async {
    final data = await _loadData();
    final list = data[slug] as List<dynamic>? ?? [];
    return list.map((j) => MediaItem.fromJson(j)).toList();
  }
}