import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/government.dart';

class GovernmentRepository {
  Map<String, dynamic>? _data;

  Future<Map<String, dynamic>> _loadData() async {
    if (_data != null) return _data!;
    final jsonString =
        await rootBundle.loadString('assets/mock/government.json');
    _data = json.decode(jsonString) as Map<String, dynamic>;
    return _data!;
  }

  Future<List<RegionalSector>> getRegionalSectors() async {
    final data = await _loadData();
    final list = data['regional_sectors'] as List<dynamic>;
    return list.map((j) => RegionalSector.fromJson(j)).toList();
  }

  Future<List<GovRegion>> getZones() async {
    final data = await _loadData();
    final list = data['zones'] as List<dynamic>;
    return list.map((j) => GovRegion.fromJson(j)).toList();
  }

  Future<List<GovRegion>> getCities() async {
    final data = await _loadData();
    final list = data['cities'] as List<dynamic>;
    return list.map((j) => GovRegion.fromJson(j)).toList();
  }

  Future<List<GovRegion>> getWoredas(int zoneId) async {
    final data = await _loadData();
    final map = data['woredas'] as Map<String, dynamic>;
    final list = map[zoneId.toString()] as List<dynamic>? ?? [];
    return list.map((j) => GovRegion.fromJson(j)).toList();
  }

  Future<List<GovRegion>> getSubCities(int cityId) async {
    final data = await _loadData();
    final map = data['sub_cities'] as Map<String, dynamic>;
    final list = map[cityId.toString()] as List<dynamic>? ?? [];
    return list.map((j) => GovRegion.fromJson(j)).toList();
  }

  Future<List<GovRegion>> getKebeles(int parentId) async {
    final data = await _loadData();
    final map = data['kebeles'] as Map<String, dynamic>;
    final list = map[parentId.toString()] as List<dynamic>? ?? [];
    return list.map((j) => GovRegion.fromJson(j)).toList();
  }
}